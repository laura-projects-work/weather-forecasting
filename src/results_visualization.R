# src/results_visualization.R

library(data.table)
library(ggplot2)
library(viridis)

# Set global theme for plots
theme_set(
  theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(size = 14, face = "bold"),
      plot.margin = margin(t = 5, r = 5, b = 5, l = 5)
    )
)

#' Merge forecast data tables
#'
#' @param results_list List of forecast data.tables.
#' @return Merged data.table with columns: date, real, and one column per model's predictions.
merge_forecasts <- function(results_list) {
  combined_forecasts <- Reduce(function(dt1, dt2) {
    merge(dt1, dt2, by = c("date", "real"), all = TRUE)
  }, lapply(names(results_list), function(model_name) {
    dt <- copy(results_list[[model_name]])
    setnames(dt, "predicted", tolower(model_name))  # Rename "predicted" column to model name
    dt[, model := NULL]  # Remove model column
    dt
  }))
  
  setorder(combined_forecasts, date)
  return(combined_forecasts)
}

#' Generalized Forecast Plotting Function
#'
#' @param combined_forecasts A data.table from merge_forecasts().
#' @param plot_type Type of plot: "time_series" (default) or "scatter".
#' @return A ggplot object.
plot_forecasts <- function(combined_forecasts, plot_type = "time_series") {
  if (plot_type == "time_series") {
    combined_forecasts_long <- melt(
      combined_forecasts, 
      id.vars = 1, 
      variable.name = "model", 
      value.name = "predicted"
    )
    
    p <- ggplot(combined_forecasts_long, aes(x = date, y = predicted, color = model)) +
      geom_line(linewidth = 0.8, alpha = 0.8) +
      scale_color_viridis_d() +
      labs(
        title = "Forecast Model Comparison",
        subtitle = "Comparing Different Forecasting Models with Real Data",
        x = "Date",
        y = "Predicted Value",
        color = NULL
      ) +
      theme(
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        plot.subtitle = element_text(size = 12)
      ) +
      guides(colour = guide_legend(nrow = 1))
    
    
  } else if (plot_type == "scatter") {
    combined_forecasts_long <- melt(
      combined_forecasts, 
      id.vars = 1:2, 
      variable.name = "model", 
      value.name = "predicted"
    )
    
    p <- ggplot(combined_forecasts_long, aes(x = real, y = predicted)) +
      geom_point(alpha = 0.2, color = "blue") +
      geom_abline(intercept = 0, slope = 1, color = "red", linewidth = 1) +
      facet_wrap(~model, scales = "free") +
      labs(
        x = "Actual Temperature", 
        y = "Predicted Temperature",
        title = "Predicted vs Actual Temperature"
      ) +
      theme(
        strip.text = element_text(size = 10, face = "bold")
      ) +
      guides(colour = guide_legend(nrow = 1))
    
  } else {
    stop("Invalid plot_type. Use 'time_series' or 'scatter'.")
  }
  
  return(p)
}

#' Plot Adjusted R-Squared values
#'
#' @param metrics_dt A data.table containing model performance metrics.
#' @return A ggplot object showing Adjusted R-Squared values.
plot_adjusted_r2 <- function(metrics_dt) {
  metrics_long <- melt(metrics_dt, 
                       id.vars = "metric", 
                       variable.name = "Model", 
                       value.name = "Value")
  
  adj_r2_data <- metrics_long[metric == "adj_r_squared"]
  adj_r2_data <- adj_r2_data[order(Value)]
  
  ggplot(adj_r2_data, aes(x = Value, y = reorder(Model, Value), fill = Model)) +
    geom_col() +
    scale_fill_viridis_d() +
    labs(
      title = "Adjusted R-Squared by Model",
      x = "Adjusted R-Squared",
      y = NULL
    ) +
    theme(
      axis.text.y = element_text(size = 10, face = "bold"),
      legend.position = "none"
    )
}

