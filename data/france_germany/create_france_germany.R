data <- read_sf('./data/france_germany/france_germany.shp')
library(tidyverse); library(giscoR); library(rnaturalearth); library(geodata)
library(cawd)
# Get LAU data
france <- giscoR::gisco_get_lau(country="France")
germany <- giscoR::gisco_get_lau(country="Germany")

# Find only European France
filt <- geodata::gadm("France", path=tempdir()) |> st_as_sf()
france <- st_intersection(france, filt)

# Put France and Germany Together
fr_gr <- bind_rows(france, germany)

# Import roads
roads <- cawd::darmc.roman.roads.major.sp |> st_as_sf()
numbers <- st_intersects(roads, fr_gr)|> 
  as.data.frame() |> select(row.id) |> pull() |> unique()
roads_in_fr_gr <- roads |> filter(is.element(row_number(), numbers))
# Calculate distance to roads
minimum_distances <- fr_gr |>
  st_centroid() |>
  st_distance(roads_in_fr_gr) |>
  apply(1, min)

# Add them to dataset
fr_gr <- fr_gr |>
  mutate(minimum_distance = minimum_distances)

# Calculate treatment=1 if road intersects municipality
treated_obs <- st_intersects(fr_gr, roads_in_fr_gr) |>
  as.data.frame() |> 
  select(row.id) |>
  pull() |> 
  unique()

fr_gr <- fr_gr |>
  mutate(treatment = if_else(is.element(row_number(), treated_obs), 1, 0))

# Plot
fr_gr |> ggplot(aes(fill=treatment)) + geom_sf()

# Save as geojson
write_sf(fr_gr, './data/france_germany/france_germany_updated.geojson')
