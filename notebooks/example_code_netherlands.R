library(tidyverse); library(sf)
ned <- st_read('./netherlands_roman_updated.geojson')

ned |> 
  ggplot(aes(fill=in_empire)) + geom_sf()

# create a running variable
data <- ned |> 
  mutate(
    in_empire = replace_na(in_empire, 0), 
    running = if_else(in_empire == 1, distance_from_border,
                           -1 * distance_from_border))

# inspect running variable
data |>
  ggplot(aes(fill = running)) + geom_sf()

# look for other data
population <- read_delim('./popned.csv') |> 
  janitor::clean_names()

# merge the population data with the spatial data.frame
data <- data |> 
  left_join(population, 
            by = c("areaname" = "gemeenten_2022"))

# calculate pop. density
data <- data |> 
  mutate(density = bevolking_totaal_1988 / area_large * 1000000)

# plot population density
data |> 
  ggplot(aes(fill = density)) + geom_sf()


# do regression discontinuity
library(rdrobust)

rdrobust::rdplot(y=data$density, x=data$running, c= 0)
rdrobust::rdrobust(y= data$density, x=data$running, c= 0) |> 
  summary()

# plot
data |> 
  ggplot(aes(x = running, y = density)) + geom_point()
