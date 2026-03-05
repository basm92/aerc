library(rdrobust)
library(tidyverse)
library(modelsummary)

make_table_column <- function(estimates, margin_dv = 0.05, extra_rows = NULL) {
  
  # Extract Treatment Effect Estimate
  est <- estimates$Estimate[1] |> round(3)
  # Extract SE
  se <- estimates$Estimate[3] |> round(3)
  # P-value and stars
  robust_p_value <- estimates$pv[3] |> round(3)
  stars = case_when(robust_p_value < 0.01 ~ "***", 
                    robust_p_value < 0.05 ~ "**",
                    robust_p_value < 0.10 ~ "*",
                    TRUE ~ "")
  
  # No. of observations
  n_control <- estimates$N[1]; n_treat <- estimates$N[2]
  
  # Bandwidth
  bw <- estimates$bws[1,1] |> round(3)
  
  data.frame(out = c(
    paste0(est, stars),
    paste0("(",se,")"),
    n_treat,
    n_control,
    bw, 
    extra_rows
  ))
}

modelsummary_rdrobust <- function(list_of_rdrobust_objects, 
                       row_names = NULL,
                       row_names_add = NULL,
                       ...){
  # Get the first row with information
  if(is.null(row_names)){
    row_names <- c("Coefficient (ITT)",
                   "SE (BC)",
                   "N (Treated)",
                   "N (Control)",
                   "Bandwidth")
    if(!is.null(row_names_add)){
      row_names <- c(row_names, row_names_add)
    }
  }
  
  # Construct Model Names
  names <- map_chr(1:length(list_of_rdrobust_objects), ~ paste0("(", .x, ")", collapse=''))
  df <- list_of_rdrobust_objects |> 
    map(make_table_column) |>
    reduce(bind_cols) 
  names(df) <- names
  
  # Together with the row names
  out <- bind_cols(" "=row_names, df)
  datasummary_df(out, ...)
}

# Example usage:
model1 <- rdrobust(mtcars$mpg, mtcars$wt, c=3)
model2 <- rdrobust(mtcars$mpg, mtcars$qsec, c = 18)

modelsummary_rdrobust(list(model1, model2))
