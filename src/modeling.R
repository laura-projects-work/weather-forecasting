# src/modeling.R
library(xgboost)
library(caret)
library(forecast)
library(prophet)
library(data.table)
source("src/utilities.R")

#' Run XGBoost forecasting.
#'
#' @param train_data Training data (data.table).
#' @param test_data Testing data (data.table).
#' @param feature_cols Vector of predictor column names.
#' @return A formatted forecast data.table.
run_xgboost <- function(train_data, test_data, feature_cols) {
  dtrain <- xgb.DMatrix(data = as.matrix(train_data[, ..feature_cols]),
                        label = train_data$temperature_2m)
  dtest <- xgb.DMatrix(data = as.matrix(test_data[, ..feature_cols]),
                       label = test_data$temperature_2m)
  params <- list(
    objective = "reg:squarederror",
    eta = 0.1,
    max_depth = 6,
    subsample = 0.8,
    colsample_bytree = 0.8,
    nthread = parallel::detectCores()
  )
  model <- xgb.train(
    params = params,
    data = dtrain,
    nrounds = 100,
    watchlist = list(train = dtrain, test = dtest),
    print_every_n = 10,
    early_stopping_rounds = 10,
    verbose = 0
  )
  preds <- predict(model, dtest)
  format_forecast(test_data, preds, "XGBoost")
}

#' Run GLMNET forecasting.
#'
#' @param train_data Training data (data.table).
#' @param test_data Testing data (data.table).
#' @param feature_cols Vector of predictor column names.
#' @return A formatted forecast data.table.
run_glmnet <- function(train_data, test_data, feature_cols) {
  formula <- as.formula(paste("temperature_2m ~", paste(feature_cols, collapse = " + ")))
  train_control <- trainControl(method = "cv", number = 5)
  glmnet_model <- train(formula, data = train_data,
                        method = "glmnet",
                        preProcess = c("center", "scale"),
                        trControl = train_control)
  preds <- predict(glmnet_model, newdata = test_data)
  format_forecast(test_data, preds, "GLMNET")
}

#' Run Cubist forecasting.
#'
#' @param train_data Training data (data.table).
#' @param test_data Testing data (data.table).
#' @param feature_cols Vector of predictor column names.
#' @return A formatted forecast data.table.
run_cubist <- function(train_data, test_data, feature_cols) {
  formula <- as.formula(paste("temperature_2m ~", paste(feature_cols, collapse = " + ")))
  train_control <- trainControl(method = "cv", number = 5)
  cubist_model <- train(formula, data = train_data,
                        method = "cubist",
                        trControl = train_control)
  preds <- predict(cubist_model, newdata = test_data)
  format_forecast(test_data, preds, "Cubist")
}

#' Run ARIMA forecasting.
#'
#' @param train_data Training data (data.table).
#' @param test_data Testing data (data.table).
#' @param feature_cols Not used (ARIMA is univariate).
#' @return A formatted forecast data.table.
run_arima <- function(train_data, test_data, feature_cols = NULL) {
  n_test <- nrow(test_data)
  ts_train <- ts(train_data$temperature_2m, frequency = 24)
  model <- auto.arima(ts_train)
  fc <- forecast(model, h = n_test)
  preds <- as.numeric(fc$mean)
  format_forecast(test_data, preds, "ARIMA")
}

#' Run Prophet forecasting.
#'
#' @param train_data Training data (data.table).
#' @param test_data Testing data (data.table).
#' @param feature_cols Not used (Prophet is univariate).
#' @return A formatted forecast data.table.
run_prophet <- function(train_data, test_data, feature_cols = NULL) {
  dt_train <- train_data[, .(ds = date, y = temperature_2m)]
  m <- prophet(dt_train)
  future <- make_future_dataframe(m, periods = nrow(test_data), freq = "hour")
  forecast <- predict(m, future)
  forecast_future <- tail(forecast, n = nrow(test_data))
  preds <- forecast_future$yhat
  format_forecast(test_data, preds, "Prophet")
}
