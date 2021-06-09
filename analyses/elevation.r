# Elevation
library(pacman)
p_load(sf,
       raster,
       rgeos,
       rasterVis, 
       leaflet, 
       dplyr)

# Loading and cleaning shapefile and elevation data
point_shp <- st_read("../data/anlaeg_all_4326.shp")
point_shp <- point_shp[!(!is.na(point_shp$anlaegsbet) & point_shp$anlaegsbet==""), ]
raster_elev <- raster('DTM_10m_20200622.tiff')

# Empty raster to reproject elevation raster with - changes to CRS WGS84
tmax <- raster(nrow=888, ncol=1848, xmn=3.875395, xmx=16.4037 , ymn=54.38102 , ymx=58.24733, crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Projection and cropping areas of interest
raster_elev_proj <- projectRaster(raster_elev, tmax)
elev <- crop(raster_elev_proj, st_bbox(point_shp))

# Extract elevation for every mound and add to data frame as Elevation column
findings_elev <- raster::extract(elev, point_shp)
point_shp$Elevation <- findings_elev

# Summarised dataframe grouped by both type of finding and municipality
finding_by_elev <- point_shp %>% 
  st_drop_geometry() %>% 
  group_by(anlaegsbet, kommunenav) %>%
  summarise(mean_elev = mean(Elevation, na.rm = TRUE), 
            sd = sd(Elevation, na.rm = TRUE)) %>% 
  na.omit() 

# Change name for compatibility with other dataframe
finding_by_elev$kommunenav <- ifelse(finding_by_elev$kommunenav=="Århus", "Aarhus", finding_by_elev$kommunenav)
finding_by_elev$kommunenav <- ifelse(finding_by_elev$kommunenav=="Vesthimmerland", "Vesthimmerlands", finding_by_elev$kommunenav)

# Save
write_csv(finding_by_elev, "../data/preprocessed/municipal_elevation.csv")

#### T test ####
# Crop elevation map to the bounding box of all findings in DK
church_test_data <- point_shp %>% filter(anlaegsbet=="Kirke" | anlaegsbet=="Bosættelse, uspec undergruppe")

# Selecting elevation for all other findings  
elev_no_church <- church_test_data %>% 
  st_drop_geometry() %>% 
  filter(anlaegsbet =="Bosættelse, uspec undergruppe") %>%
  dplyr::select(Elevation) %>% 
  drop_na()

# Selecting elevation for churches 
elev_church <- church_test_data %>% 
  st_drop_geometry() %>% 
  filter(anlaegsbet =='Kirke') %>%
  dplyr::select(Elevation) %>% 
  drop_na()

church_test_data %>% 
  group_by(anlaegsbet) %>% 
  summarise(mean_ele=mean(Elevation, na.rm = TRUE), 
            sd_ele = sd(Elevation, na.rm = TRUE)) %>% 
  print()

# Performing t-test
t.test(elev_church, elev_no_church)
