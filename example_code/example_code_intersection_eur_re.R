library(sf)
library(tidyverse)
library(rnaturalearth)
library(cawd)
re <- cawd::awmc.roman.empire.117.sp |> st_as_sf()
eur <- rnaturalearthdata::countries50 |> st_as_sf() |>
  filter(continent == "Europe")
sf::sf_use_s2(FALSE)
eur_in_re <- st_intersection(re, eur)
eur_in_re |>
  ggplot() + geom_sf()
cawd::orbis.nodes
