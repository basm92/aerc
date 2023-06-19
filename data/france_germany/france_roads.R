library(sf); library(tidyverse)
# Download the roads from:
# https://geoservices.ign.fr/route500#telechargement or direct link:
# https://wxs.ign.fr/pfinqfa9win76fllnimpfmbi/telechargement/inspire/ROUTE500-France-2021$ROUTE500_3-0__SHP_LAMB93_FXX_2021-11-03/file/ROUTE500_3-0__SHP_LAMB93_FXX_2021-11-03.7z

# import roads (or a part of it, say 100000 obs)
france_routes <- st_read("./ROUTE500_3-0__SHP_LAMB93_FXX_2021-11-03/ROUTE500/1_DONNEES_LIVRAISON_2022-01-00175/R500_3-0_SHP_LAMB93_FXX-ED211/RESEAU_ROUTIER/TRONCON_ROUTE.shp") |>
  filter(!is.na(NUM_ROUTE))
france_routes <- france_routes[1:100000,] # first observations

# save coord system of roads
crs <- st_crs(france_routes)

# import municipalities
france_communes <- st_read('./FRA_shp/gadm36_FRA_5.shp') |>
  st_transform(crs) |> 
  mutate(total_area = as.numeric(st_area(geometry)))

# compute a dataset with buffers for roads
# put roads temporariliy in a coordinate system using meters, and then put it pack again
france_routes <- st_transform(france_routes, "+proj=utm +zone=30 +datum=WGS84 +units=m +no_defs")
roads_buffer <- st_buffer(france_routes, 10)
roads_buffer <- roads_buffer |> st_transform(crs)

#bereken de oppervlakte van de wegen als deel van de gemeente
intersected <- st_intersection(roads_buffer, france_communes)
intersected$area <- st_area(intersected)
test <- aggregate(intersected$area, by = list(intersected$GID_5), FUN = sum)
france_communes <- france_communes |> 
  left_join(test, by=c("GID_5"="Group.1")) |>
  mutate(sufrace = as.numeric(x) / total_area) |> 
  mutate(sufrace = case_when(sufrace > 1 ~ 1,
                             is.na(sufrace) ~ 0,
                             TRUE ~ sufrace))

# save the particular part (mind the name)
write_sf(france_communes, './france_communes_first_100000.shp')

# check the plot if you want
france_communes |> 
  ggplot(aes(fill = log(1+sufrace))) + geom_sf(lwd=0.0001) + scale_fill_viridis_c()

# the total data.frame is of course the sum of the sufrace columns in the different parts
