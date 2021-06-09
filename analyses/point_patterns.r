library(pacman)

p_load(spatstat, 
       sf, 
       raster, 
       dplyr, 
       tmap, 
       spData, 
       maptools,
       ggplot2)

# Loading and cleaning shapefile of findings and borders
point_shp <- st_read("../data/anlaeg_all_25832.shp")
point_shp <- point_shp[!(!is.na(point_shp$anlaegsbet) & point_shp$anlaegsbet==""), ]
møntfund <- point_shp %>% filter(anlaegsbet == "Møntfund")
havne <- point_shp %>% filter(anlaegsbet == "Havn")

borders <- st_read("country_border/ne_10m_admin_0_countries.shp")
dk_shape <- borders %>% filter(NAME=="Denmark")

# Transform borders to owin window
dk_shape_utm <- sf::st_transform(dk_shape, crs = st_crs(møntfund)$proj4string)
dk_border_owin <- as.owin(sf::as_Spatial(dk_shape_utm))

# Change coins and harbour data to ppp object
møntfund_ppp <- as(as_Spatial(møntfund), "ppp")
havn_ppp <- as(as_Spatial(havne), "ppp")

# Planar point pattern
point_pattern_border <- ppp(møntfund_ppp$x, # "Planar point pattern" is jargon for a set of points in a region of a 2D plane
                            møntfund_ppp$y, 
                            window = dk_border_owin, 
                            unitname=c("metre","metres")) # window is the window of observation, an object of class "owin"

# Counting points in quadrats in point_pattern_border and performing quadrat test
test <- quadratcount(point_pattern_border, nx=25)
quadrat.test(test)

# Plotting with Bornholm
plot(intensity(test, image=TRUE), main=NULL, las=1)  # Plot density raster - The density values are reported as the number of points (stores) per square meters, per quadrat.
plot(havne, add=TRUE, col= "#33CAFF", cex=1)

# Plotting without Bornholm
no_bornholm <- møntfund %>% filter(kommunenav!="Bornholm")
no_bornholm_ppp <- as(as_Spatial(no_bornholm), "ppp")

point_pattern_border_no_bornholm <- ppp(no_bornholm_ppp$x, # "Planar point pattern" is jargon for a set of points in a region of a 2D plane
                                        no_bornholm_ppp$y, 
                                        window = dk_border_owin, 
                                        unitname=c("metre","metres")) # window is the window of observation, an object of class "owin"

test_no_bornholm <- quadratcount(point_pattern_border_no_bornholm, nx=25)
quadrat.test(test_no_bornholm)
plot(intensity(test_no_bornholm))
intensity(test_no_bornholm, image=TRUE)
plot(intensity(test_no_bornholm, image=TRUE), main=NULL, las=1)  # Plot density raster - The density values are reported as the number of points (stores) per square meters, per quadrat.
plot(havne, add=TRUE, col= "#33CAFF", cex=1)