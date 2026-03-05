library(sf); library(tidyverse)

fr_gr <- sf::st_read('./shapefiles/france_germany.shp')

fr_gr |> 
  ggplot() + geom_sf()

data <- fr_gr |> 
  filter(!is.na(tretmnt)) 


library(fixest)
m1 <- fixest::feols(POP_DEN ~ tretmnt, data = data)
m2 <- fixest::feols(POP_DEN ~ tretmnt | nuts_2, data = data)
m3 <- fixest::feols(POP_DEN ~ tretmnt | nuts_2 + nuts_3, data = data)


library(modelsummary)
modelsummary::modelsummary(list(m1, m2, m3), stars = T)
