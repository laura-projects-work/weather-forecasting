# src/utilities.R
library(data.table)

#' Time a function's execution.
#'
#' @param f A function.
#' @param ... Additional arguments passed to f.
#' @return A list with the function result and elapsed time (in seconds).
time_it <- function(f, ...) {
  start_time <- Sys.time()
  result <- f(...)
  elapsed_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  list(result = result, elapsed_time = elapsed_time)
}


#' Format forecast output into a standard data.table.
#'
#' @param test_data A data.table with original test data.
#' @param preds Vector of forecasted values.
#' @param model_name A string naming the model.
#' @return A data.table with columns: date, predicted, real, and model.
format_forecast <- function(test_data, preds, model_name) {
  test_data[, predicted := preds]
  forecasted_real <- test_data[, .(date, predicted, real = temperature_2m)]
  forecasted_real[, model := model_name]
  forecasted_real
}