## provide a map or three maps (one for each species)-->selection of individuals


###############################################################################
# library

library(tidyverse)
library(dplyr)
library(countrycode)
library(maptools)
library(rnaturalearthdata)
library(rnaturalearth)
library("ggspatial")
library("gridExtra")

###############################################################################
## function

## print mediteranean sea map

medMap <- function(monTitre, spec.df) {
  
  
  world <- ne_countries(scale = "medium", returnclass = "sf")
  gG <- ggplot(data = world) +
    geom_sf() +
    geom_point(data=spec.df, aes(x=lon, y=lat), col="red", shape=3, size=2)+
    annotation_scale(location = "bl", width_hint = 0.5) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                           style = north_arrow_fancy_orienteering) +
    coord_sf(xlim = c(-9, 12), ylim = c(36, 44))+
    labs(title = monTitre,
         subtitle = "",
         caption = "",
         tag = "",
         x = "",
         y = "",
         colour = "")+
    theme(title=element_text(size=24),
          text=element_text(size=18))
  return(gG)
  
}


###############################################################################
## data

## load table S7
samp <- read.csv("coords/sample.csv", sep=";", header=T)


###############################################################################
## draw map
## diplodus
dip <- samp %>% filter(species== "Diplodus sargus")
dip.df <- data.frame(lat = dip$latitude, lon= dip$longitude,depth=dip$depth)
dip.gg <- medMap("a", dip.df)
## mullus
mul <- samp %>% filter(species== "Mullus surmuletus")
mul.df <- data.frame(lat = mul$latitude, lon= mul$longitude,depth=mul$depth)
mul.gg <- medMap("b", mul.df)
## serran
ser <- samp %>% filter(species== "Serranus cabrilla")
ser.df <- data.frame(lat = ser$latitude, lon= ser$longitude,depth=ser$depth)
ser.gg <- medMap("c", ser.df)

##########################################################################
## write pdf files
pdf("coords/figureS7.pdf",width=16,height=14,paper='special')
grid.arrange(dip.gg, mul.gg, ser.gg , nrow=2)
dev.off()



