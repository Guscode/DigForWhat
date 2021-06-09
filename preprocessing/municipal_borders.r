library(pacman)
p_load(tidyverse, leaflet, dplyr, sf)

# Reading file with municipal border (1:2 mil)
municipalities_mil <- st_read("KOMMUNE.shp") %>% dplyr::select(geometry, KOMNAVN) %>%  st_transform(crs = st_crs(4326)) %>% st_zm()

# Using st_union to create one polygon of each municipality
united_municipalities_mil <- municipalities_mil %>% 
    group_by(KOMNAVN) %>%
    summarise(geometry = sf::st_union(geometry)) %>%
    ungroup()

# Writing shapefile
st_write(united_municipalities_mil, "municipal_mil_united.shp")
write.csv(united_municipalities_mil$KOMNAVN, "kommun.csv")