# src/data_preprocessing.R
library(data.table)
library(lubridate)

#' Load data from a CSV and filter by year.
#'
#' @param file_path The path to the CSV file.
#' @param years A vector of years to include.
#' @return A data.table with the filtered data.
load_data <- function(file_path, years) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }
  dt <- fread(file_path)
  dt <- dt[year(date) %in% years]
  dt
}

#' Remove predictors that are highly correlated with the target.
#'
#' @param dt A data.table.
#' @param target The name of the target variable.
#' @param threshold The correlation threshold above which predictors are removed.
#' @return The data.table with high-correlation predictors removed.
remove_highly_correlated <- function(dt, target = "temperature_2m", threshold = 0.80) {
  numeric_vars <- names(dt)[sapply(dt, is.numeric)]
  predictors <- setdiff(numeric_vars, target)
  
  # Compute correlations vectorized over .SD
  cor_target <- dt[, lapply(.SD, function(x) cor(x, get(target), use = "complete.obs")), .SDcols = predictors]
  cor_target <- unlist(cor_target)
  
  # Remove predictors whose absolute correlation exceeds threshold
  remove_vars <- names(cor_target)[abs(cor_target) > threshold]
  if (length(remove_vars) > 0) {
    dt[, (remove_vars) := NULL]
  }
  dt
}

#' Add Fourier-based time features to capture periodic patterns.
#'
#' @param dt A data.table with a "date" column.
#' @return The data.table with added Fourier features.
add_fourier_features <- function(dt) {
  if (!"date" %in% names(dt)) {
    stop("The data table must contain a 'date' column.")
  }
  dt[, `:=`(
    hour = hour(date),
    doy = yday(date),
    year_length = ifelse(leap_year(year(date)), 366, 365)
  )]
  dt[, t := doy / year_length]
  dt[, `:=`(
    sin_hour = sin(2 * pi * hour / 24),
    cos_hour = cos(2 * pi * hour / 24),
    sin_day  = sin(2 * pi * t),
    cos_day  = cos(2 * pi * t)
  )]
  setorder(dt, date)
  dt[, `:=`(hour = NULL, doy = NULL, t = NULL, year_length = NULL)]
  dt
}

#' Split data into training and testing sets.
#'
#' @param dt A data.table.
#' @param train_frac Fraction of data for training.
#' @return A list with elements "train" and "test".
split_data <- function(dt, train_frac = 0.8) {
  n <- nrow(dt)
  train_index <- 1:floor(train_frac * n)
  test_index <- (floor(train_frac * n) + 1):n
  list(train = dt[train_index], test = dt[test_index])
}
