# Load necessary packages
library(osmdata)
library(sf)

# Function to convert bounding box to polygon
bbox_to_polygon <- function(location) {
  # Get bounding box from osmdata
  bbox <- getbb(location)
  
  # Extract min and max coordinates
  min_x <- bbox["x", "min"]
  max_x <- bbox["x", "max"]
  min_y <- bbox["y", "min"]
  max_y <- bbox["y", "max"]
  
  # Create a matrix of the coordinates for the polygon
  coords <- matrix(c(
    min_x, min_y,
    max_x, min_y,
    max_x, max_y,
    min_x, max_y,
    min_x, min_y
  ), ncol = 2, byrow = TRUE)
  
  # Create the polygon
  polygon <- st_polygon(list(coords))
  
  # Create an sf object
  sf_polygon <- st_sfc(polygon, crs = 4326)
  
  return(sf_polygon)
}

# Example usage
location <- "Utrecht"
polygon <- bbox_to_polygon(location)

# Now implement this for an entire dataframe
## Make function to implement it for one row
polygon_from_row <- function(row){
  # Change row$location to the appropriate name for the city
  loc <- row$location
  bbox_to_polygon(loc)
}

## Implement it in all rows
df <- df |>
  rowwise() |>
  mutate(polygon = polygon_from_row(cur_data()))

