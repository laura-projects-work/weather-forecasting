# Time Series Forecasting Helper Functions

This repository provides a collection of R helper functions to support time series forecasting using multiple modeling techniques, including XGBoost, GLMNET, Cubist, ARIMA, and Prophet. The functions include data preprocessing, model training, forecasting, and performance evaluation utilities—all designed to streamline your forecasting workflow.

## Project Structure

project/
├── data/
│   ├── hourly_data.csv         # Your dataset
│   └── get_data.ipynb          # (Optional) Notebook for data exploration or retrieval
├── src/
│   ├── utilities.R             # General helper functions (e.g., time_it)
│   ├── data_preprocessing.R    # Functions for loading and preprocessing data
│   ├── metrics.R               # Function(s) to compute performance metrics
│   ├── formatting.R            # Function(s) to format forecast output
│   ├── modeling.R              # All modeling functions (XGBoost, GLMNET, Cubist, ARIMA, Prophet)
│   └── main.R                  # Main workflow script that ties everything together
└── README.md                   # Project documentation




## Features

- **Data Preprocessing**
  - Load data with filtering by year.
  - Remove predictors highly correlated with the target.
  - Add Fourier-based time features to capture periodic patterns.

- **Modeling Functions**
  - **XGBoost:** Regression using gradient boosting.
  - **GLMNET:** Penalized regression.
  - **Cubist:** Rule-based regression.
  - **ARIMA:** Univariate time series forecasting.
  - **Prophet:** Forecasting using Facebook's Prophet.

- **Performance Evaluation**
  - Compute metrics including RMSE, R-squared, and adjusted R-squared.

- **Utility Functions**
  - `time_it()`: Measure the execution time of any function.
  - `format_forecast()`: Standardize the output of model forecasts.

## Requirements

- **R** (version ≥ 3.5 recommended)
- Required R packages:
  - `data.table`
  - `ggplot2`
  - `lubridate`
  - `caret`
  - `xgboost`
  - `Metrics`
  - `forecast`
  - `prophet`
  - *(Optional for parallel processing)* `doParallel`, `foreach`
