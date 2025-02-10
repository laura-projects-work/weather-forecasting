# Weather Forecasting (Time Series)

This repository contains a comprehensive framework for weather forecasting using time series data. The project integrates advanced data preprocessing, various modeling techniques, performance evaluation, and result visualization.


---

## Project Structure
```bash
project/
├── data/
│   ├── hourly_data.csv           # Dataset
│   └── get_data.ipynb            # Notebook for data retrieval
├── src/
│   ├── utilities.R               # General helper functions
│   ├── data_preprocessing.R      # Functions for loading and preprocessing data
│   ├── metrics.R                 # Function to compute performance metrics
│   ├── modeling.R                # All modeling functions (XGBoost, GLMNET, Cubist, ARIMA, Prophet)
│   ├── main.R                    # Main workflow script that ties everything together
│   └── results_visualization.R   # Functions for visualizing forecasts and evaluation results
└── README.md                     # Project documentation
```


---

## Features

- **Data Preprocessing**
  - Load data.
  - Remove predictors highly correlated with the target.
  - Add Fourier-based time features to capture periodic patterns.

- **Modeling Functions**
  - **XGBoost:** Regression using gradient boosting.
  - **GLMNET:** Penalized regression.
  - **Cubist:** Rule-based regression.
  - **ARIMA:** Univariate time series forecasting.
  - **Prophet:** Forecasting using Facebook's Prophet.

- **Performance Evaluation**
  - Compute RMSE, R-squared, and adjusted R-squared.

- **Utility Functions**
  - `time_it()`: Measure the execution time of any function.
  - `format_forecast()`: Standardize the output of model forecasts.

---

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
 
---

## Installation and Setup
1. Clone the project repository to your local machine:
```bash
git clone https://github.com/yourusername/weather-forecasting.git
cd weather-forecasting
```

2. Install Required R Packages
```bash
install.packages(c("data.table", "ggplot2", "lubridate", "caret", "xgboost", "Metrics", "forecast", "prophet"))
# For optional parallel processing support:
install.packages(c("doParallel", "foreach"))
```

3. Data Setup
Ensure that the dataset (hourly_data.csv) is present in the data/directory. Alternatively, run the get_data.ipynb notebook to retrieve and prepare the data.
