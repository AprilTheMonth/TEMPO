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
  folder <- "Hartford, CT"
}

files = list.files(folder, pattern="*[.]RData", full.names=TRUE, recursive=TRUE)
#print(files)
print("loading files")
allData <- NULL
for (f in seq_along(files)) {
  load(files[f])
  allData <- rbind(allData, data)
}
#print(head(allData))
data <- allData
print("all files loaded")
#load(paste(folder, "RData/tempo.l2.no2.vertical_column_troposphere_2025-04-04T000000Z_2025-04-05T000000Z.RData", sep="/"))
roc <- read_sf(paste(folder, "tracts/city_with_tracts.shp", sep="/"))

#plot(st_geometry(tracts))
data$id <- 1:length(data[,1])
values <- data.frame(id = 1:length(data[,1]), value = data$no2)
ids <- rep(1:length(data[,1]), each=4)
bboxes <- data.frame(id = ids, x = (unlist(data$longitude_bb)), y = unlist(data$latitude_bb))
datapoly <- merge(values, bboxes, by=c("id"))

print("starting merge")
sf <- datapoly %>% st_as_sf(coords = c("x", "y")) %>% group_by(id) %>% summarise(geometry = st_combine(geometry)) %>% st_cast("POLYGON")
st_crs(sf) <- 4326
species <- data.frame(id=data$id, no2=data$no2, hcho=data$hcho)
sf <- st_sf(merge(species, sf), sf_column_name = "geometry")
print("merge finished")
#sf$no2 <- oob_squish(sf$no2, range=c(0, 2e+16)) / 2e+16
#sf$hcho <- oob_squish(sf$hcho, range=c(0, 2e+16)) / 2e+16
sf$ratio <- sf$hcho / sf$no2

sf <- st_transform(sf, 4269)
print("starting intersection... this could take a while")
i = st_intersects(roc, sf)
roc$NO2 <- NA*length(roc$NAME)
roc$HCHO <- NA*length(roc$NAME)
roc$RATIO <- NA*length(roc$NAME)

# TODO: weight averages by % covered by TEMPO pixel 
for (x in seq_along(i)) {
  # x represents a census tract in the city
  tract_geom <- roc$geometry[x]
  mean_NO2 <- 0
  mean_HCHO <- 0
  total_weight <- 0
  if (length(sf$no2[x]) > 0) {
    for (y in i[[x]]) {
      weight <- as.numeric(st_area(st_intersection(roc$geometry[x], sf$geometry[y])) / st_area(roc$geometry[x]))
      mean_NO2 <- mean_NO2 + (weight * sf$no2[y])
      mean_HCHO <- mean_HCHO + (weight * sf$hcho[y])
      total_weight <- total_weight + weight
    }
    

    roc$NO2[x] <- mean_NO2 / total_weight
    roc$HCHO[x] <- mean_HCHO / total_weight
    roc$RATIO[x] <- roc$NO2[x] / roc$HCHO[x]
  }
}

print("intersection finished")

dir.create(paste(folder, "pollution_shapefile", sep="/"))

st_write(roc, paste(folder, "pollution_shapefile/pollution.shp", sep="/"), append=F)
g <- ggplot(data=roc) + geom_sf(aes(fill=NO2), linewidth=0.1) + scale_fill_viridis_c()
ggsave(g, file=paste(folder, "NO2Pollution.png", sep="/"))
g2 <- ggplot(data=roc) + geom_sf(aes(fill=HCHO), linewidth=0.1) + scale_fill_viridis_c()
ggsave(g2, file=paste(folder, "HCHOPollution.png", sep="/"))
g3 <- ggplot(data=roc) + geom_sf(aes(fill=RATIO), linewidth=0.1) + scale_fill_viridis_c()
ggsave(g3, file=paste(folder, "PollutionRatio.png", sep="/"))
