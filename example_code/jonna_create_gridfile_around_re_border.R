library(cawd)
library(rnaturalearthdata)
library(tidyverse)
library(sf)
# remotes::install_github("michaeldorman/nngeo")
library(nngeo)

# Download map of Europe 
europe <- rnaturalearthdata::sovereignty50 |>
  st_as_sf() |>
  filter(continent == "Europe")

# Download map of Roman Empire
re <- cawd::awmc.roman.empire.117.sp |> st_as_sf()

# Extract Border Roman Empire
boundary_re <- st_boundary(re)

# Extract Northern Border Roman Empire
countries_with_north_border <- europe |> filter(is.element(sovereignt, c("Netherlands", "Germany", "Croatia",
                                                                   "Austria", "Hungary", "Slovakia",
                                                                   "Ukraine", "Romania", "Bulgaria",
                                                                   "Republic of Serbia")))

# Filter the LINESTRING(s) with the maximum Y-coordinate
northernmost_lines <- st_intersection(boundary_re, countries_with_north_border) 

# Filter out south border of Croatia
coords <- matrix(c(
  15, 46,
  20, 42,
  10, 42,
  10, 46,
  15, 46), ncol = 2, byrow = TRUE)

# Create a polygon object
polygon <- st_polygon(list(coords)) |>
  st_sfc(crs = 4326)

northernmost_border <- northernmost_lines |> 
  st_difference(polygon)

# Build Buffer Around Roman Empire Border and Intersection With Europe
sf_use_s2(TRUE)
buffer_around_northern_border <- st_buffer(northernmost_border, 200000)

# Intersection with Europe
sf_use_s2(FALSE)
area_around_re_border <- europe |>
  st_intersection(buffer_around_northern_border)

# Check what this area looks like
area_around_re_border |>
  ggplot() + geom_sf()

# Build a grid on this basis
grid <- st_make_grid(area_around_re_border,  n = 100) 
filter <- st_within(grid, st_union(area_around_re_border)) |> lengths() > 0

# Check grid
final_grid <- grid[filter]

# Turn grid into an empty raster and save
library(stars); library(starsExtra)
raster_grid <- grid[filter] |> stars::st_as_stars() 
final_raster_grid <- raster_grid[raster_grid['values'] ==1]
stars::write_stars(final_raster_grid, './example_code/raster_re.tiff')


ggplot() + 
  geom_stars(data=final_raster_grid) +
  geom_sf(data=boundary_re)

# Create distance to the border:
nearest_feat <- starsExtra::dist_to_nearest(final_raster_grid, northernmost_lines)
final_raster_grid$distance <- nearest_feat$d

# Create azimuth to the border:
st_apply(final_raster_grid['values'], 1, function(x) (median(x, na.rm=T)))
final_raster_grid
