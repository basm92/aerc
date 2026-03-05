# create_wijk_level_distance
# url: https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/wijk-en-buurtkaart-2022
# Download: wijkbuurtkaart_2022_v1.zip
# unzip in wd and import
library(sf); library(tidyverse) ; library(cawd)

roman_empire <- cawd::awmc.roman.empire.117.sp |> st_as_sf()  
crs <- st_crs(roman_empire)
wijk <- sf::read_sf('./Downloads/WijkBuurtkaart_2022_v1/wijk_2022_v1.shp') |> st_transform(crs)

# make distance negative if above border, positive if inside border
numbers <- st_intersects(st_centroid(wijk), roman_empire) |> as.data.frame() |> select(row.id) |> pull()
wijk <- wijk |> 
  mutate(in_roman_empire = as.factor(if_else(is.element(row_number(), numbers), 1, 0)))

# create borders
boundary <- wijk |> 
  filter(in_roman_empire == 1) |>
  st_union() |>
  st_boundary() 

point1 <- c(4.5, 52.5)
point2 <- c(4.5, 53)
point3 <- c(6.4, 53)
point4 <- c(6.4, 51.75)
point5 <- c(5.5, 51.75)
point6 <- c(4.5, 52.5)

coords <- list(rbind(point1, point2, point3, point4, point5, point6))
poly_coords <- st_polygon(coords)

poly_c <- st_sfc(poly_coords, crs = st_crs(crs))
poly_l <- st_sf(poly_c) |> rename(geometry = poly_c)

border <- st_intersection(boundary, poly_l)

# compute distances to border
distances <- st_distance(st_centroid(wijk), border) |> 
  apply(1, min)

wijk <- wijk |> 
  mutate(distance_to_border = distances)

# compute running variable (pos. distance if in empire, neg. otherwise)
wijk <- wijk |> 
  mutate(running = if_else(in_roman_empire == 1, distance_to_border/1000, -distance_to_border/1000))

# export file
sf::write_sf(wijk, 'distance_to_border_wijk.shp')
