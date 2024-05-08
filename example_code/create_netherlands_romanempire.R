library(sf); library(tidyverse); library(geodata)
# Roman Empire
re <- cawd::awmc.roman.empire.117.sp |>
  st_as_sf()
# Get the Municipal Data
municipalities <- gadm("Netherlands", level=2, path=tempdir()) |> 
  st_as_sf() |>
  select(NAME_1, NAME_2)
# Is the municipality inside the roman empire?
is_in_re <- st_intersects(municipalities, re)
is_in_re <- is_in_re |> as.numeric()

# Compute whether municipality is in empire
municipalities <- municipalities |>
  mutate(is_in_re = if_else(is.na(is_in_re), 0, is_in_re))

# Compute area
municipalities <- municipalities |>
  mutate(area = st_area(municipalities))

# Compute border
boundary <- re |> st_boundary() |> st_intersection(municipalities)
# Only within the box
# Define the coordinates of the points
coords <- matrix(c(4.6, 52.5,
                   4.6, 52.6,
                   6.4, 52.3,
                   6.4, 51.7,
                   4.6, 52.5), ncol = 2, byrow = TRUE)
# Convert LINESTRING to POLYGON
bounding_box_polygon <- st_polygon(list(coords))
# Create a simple feature with the polygon
bounding_box_sf <- st_sf(geometry = st_sfc(bounding_box_polygon))
# Set the Coordinate Reference System (CRS)
st_crs(bounding_box_sf) <- 4326
# Create final boundary
final_boundary <- st_intersection(boundary |> st_union(), bounding_box_sf)

# Distance to border:
distances <- municipalities |>
  st_centroid() |>
  st_distance(final_boundary)

# Add to df
municipalities <- municipalities |>
  mutate(distance_to_border = as.numeric(if_else(is_in_re == 1, distances, - distances)))

# Plot
municipalities |> ggplot(aes(fill=distance_to_border)) + geom_sf()

# Export to geojson
municipalities |> write_sf('./data/netherlands/netherlands_roman_updated.geojson')
