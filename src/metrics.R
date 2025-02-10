# src/metrics.R
library(Metrics)

#' Compute performance metrics for forecasts.
#'
#' @param test A data.table with columns "real" and "predicted".
#' @param n_predictors Number of predictors (for adjusted R-squared).
#' @return A named vector with rmse, r_squared, and adj_r_squared.
compute_metrics_vector <- function(test, n_predictors) {
  real <- test$real
  predicted <- test$predicted
  n_test <- nrow(test)
  
  SSE <- sum((real - predicted)^2)
  SST <- sum((real - mean(real))^2)
  r_squared <- 1 - SSE / SST
  adj_r_squared <- 1 - (1 - r_squared) * ((n_test - 1) / (n_test - n_predictors - 1))
  
  rmse_value <- round(rmse(real, predicted), 3)
  c(rmse = rmse_value,
    r_squared = round(r_squared, 3),
    adj_r_squared = round(adj_r_squared, 3))
}
