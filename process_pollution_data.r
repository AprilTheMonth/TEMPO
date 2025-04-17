list.of.packages <- c("ggplot2", "scales", "sf", "tidyverse", "raster", "stars", "viridis")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(ggplot2)
library(scales)
library(sf)
library(tidyverse)
library(raster)
library(stars)
library(viridis)

args <- commandArgs(TRUE)
folder <- args[1]

if (is.na(folder)) {
  #stop("Please give a folder name of the form \'Boston, MA\'")
  folder <- "Rochester, NY"
}

files = list.files(folder, pattern="*[.]RData", full.names=TRUE, recursive=TRUE)
print(files)
allData <- NULL
for (f in seq_along(files)) {
  load(files[f])
  allData <- rbind(allData, data)
}
print(head(allData))
data <- allData
#load(paste(folder, "RData/tempo.l2.no2.vertical_column_troposphere_2025-04-04T000000Z_2025-04-05T000000Z.RData", sep="/"))
roc <- read_sf(paste(folder, "tracts/city_with_tracts.shp", sep="/"))

#plot(st_geometry(tracts))
data$id <- 1:length(data[,1])
values <- data.frame(id = 1:length(data[,1]), value = data$no2)
ids <- rep(1:length(data[,1]), each=4)
bboxes <- data.frame(id = ids, x = (unlist(data$longitude_bb)), y = unlist(data$latitude_bb))
datapoly <- merge(values, bboxes, by=c("id"))

sf <- datapoly %>% st_as_sf(coords = c("x", "y")) %>% group_by(id) %>% summarise(geometry = st_combine(geometry)) %>% st_cast("POLYGON")
st_crs(sf) <- 4326
species <- data.frame(id=data$id, no2=data$no2, hcho=data$hcho)
sf <- st_sf(merge(species, sf), sf_column_name = "geometry")

#sf$no2 <- oob_squish(sf$no2, range=c(0, 2e+16)) / 2e+16
#sf$hcho <- oob_squish(sf$hcho, range=c(0, 2e+16)) / 2e+16
sf$ratio <- sf$hcho / sf$no2

sf <- st_transform(sf, 4269)
print("starting intersection... this could take a while")
i = st_intersects(roc, sf)
print("intersection finished")
roc$NO2 <- NA*length(roc$NAME)
roc$HCHO <- NA*length(roc$NAME)
roc$RATIO <- NA*length(roc$NAME)
for (x in seq_along(i)) {
  if (length(sf$no2[x]) > 0) {
    roc$NO2[x] <- mean(sf$no2[x])
    roc$HCHO[x] <- mean(sf$hcho[x])
    roc$RATIO[x] <- mean(sf$ratio[x])
  }
}

dir.create(paste(folder, "pollution_shapefile", sep="/"))

st_write(roc, paste(folder, "pollution_shapefile/pollution.shp", sep="/"))
g <- ggplot(data=roc) + geom_sf(aes(fill=NO2)) + scale_fill_viridis_c()
ggsave(g, file=paste(folder, "NO2Pollution.png", sep="/"))
g2 <- ggplot(data=roc) + geom_sf(aes(fill=HCHO)) + scale_fill_viridis_c()
ggsave(g2, file=paste(folder, "HCHOPollution.png", sep="/"))
g3 <- ggplot(data=roc) + geom_sf(aes(fill=RATIO)) + scale_fill_viridis_c()
ggsave(g3, file=paste(folder, "PollutionRatio.png", sep="/"))
