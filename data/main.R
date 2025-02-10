# src/main.R
# Main workflow script

rm(list = ls())

library(data.table)
library(doParallel)
library(foreach)

# Source all modules
source("src/utilities.R")
source("src/data_preprocessing.R")
source("src/metrics.R")
source("src/modeling.R")
source("src/results_visualization.R")

main <- function() {
  file_path <- "data/hourly_data.csv"
  message("Loading data from: ", file_path)
  
  data <- load_data(file_path, years = 2002:2004)
  data <- remove_highly_correlated(data, target = "temperature_2m", threshold = 0.80)
  data <- add_fourier_features(data)
  
  feature_cols <- setdiff(names(data), c("temperature_2m", "date"))
  p <- length(feature_cols)
  
  message("Preview of processed data:")
  print(head(data))
  
  splits <- split_data(data, train_frac = 0.8)
  train_data <- splits$train
  test_data <- splits$test
  
  model_list <- list(
    XGBoost = function() run_xgboost(train_data, test_data, feature_cols),
    GLMNET  = function() run_glmnet(train_data, test_data, feature_cols),
    Cubist  = function() run_cubist(train_data, test_data, feature_cols),
    ARIMA   = function() run_arima(train_data, test_data),
    Prophet = function() run_prophet(train_data, test_data)
  )
  
  cores <- parallel::detectCores()
  cl <- makeCluster(cores)
  
  clusterEvalQ(cl, {
    source("src/utilities.R")
    source("src/data_preprocessing.R")
    source("src/metrics.R")
    source("src/modeling.R")
    NULL
  })
  
  registerDoParallel(cl)
  
  timings <- foreach(model_name = names(model_list),
                     .packages = c("data.table", "caret", "xgboost", "prophet", "forecast")) %dopar% {
                       res <- time_it(model_list[[model_name]])
                       list(name = model_name, result = res$result, elapsed_time = res$elapsed_time)
                     }
  
  stopCluster(cl)
  
  results_list <- list()
  for (item in timings) {
    message(item$name, " Model completed in ", round(item$elapsed_time, 2), " seconds.")
    results_list[[item$name]] <- item$result
  }
  
  combined_forecasts <- merge_forecasts(results_list)
  
  plot_time_series <- plot_forecasts(combined_forecasts)
  print(plot_time_series)
  plot_comparison <- plot_forecasts(combined_forecasts, "scatter")
  print(plot_comparison)
  
  metrics_list <- list(
    XGBoost = compute_metrics_vector(results_list[["XGBoost"]], n_predictors = p),
    GLMNET  = compute_metrics_vector(results_list[["GLMNET"]],  n_predictors = p),
    Cubist  = compute_metrics_vector(results_list[["Cubist"]],  n_predictors = p),
    ARIMA   = compute_metrics_vector(results_list[["ARIMA"]],   n_predictors = 0),
    Prophet = compute_metrics_vector(results_list[["Prophet"]], n_predictors = 0)
  )
  
  metrics_dt <- data.table(metric = names(metrics_list[["XGBoost"]]))
  for (model_name in names(metrics_list)) {
    metrics_dt[, (model_name) := metrics_list[[model_name]]]
  }
  message("Performance Metrics:")
  print(metrics_dt)
  plot_adjusted_r2 <- plot_adjusted_r2(metrics_dt)
  print(plot_adjusted_r2)
  
}

if (sys.nframe() == 0) {
  main()
}