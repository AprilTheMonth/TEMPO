# Install uninstalled packages
list.of.packages <- c("sf", "tidyverse", "ggplot2", "dplyr", "raster", "viridis")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(sf)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(raster)
library(viridis)

# Fetch command line arguments
args <- commandArgs(TRUE)
folder <- args[1]

# Default to Rochester, NY if no command lines
if (is.na(folder)) {
  folder <- "Rochester, NY"
}

# Load census demographic data
demo_location <- paste(folder, "demographics_shapefile/demographics.shp", sep="/")
demo <- read_sf(demo_location)

# load pollution data
poll_location <- paste(folder, "pollution_shapefile/pollution.shp", sep="/")
poll <- read_sf(poll_location)

# Merge the two sources of data
# Rochester, Albany, Syracuse, Buffalo, NYC
# Phoenix, Arizona
merged <- st_intersection(demo, poll)

# Perform the statistical analysis on each source
total_NO2_white <- (sum((merged$NO2 * merged$WHITEPE), na.rm=T) / sum(merged$WHITEPE, na.rm=T))
total_NO2_nonwhite <- (sum((merged$NO2 * (1 - merged$WHITEPE)), na.rm=T) / (sum(1-merged$WHITEPE, na.rm=T)))

med_income <- median(merged$INCOME, na.rm=T)
high_income_NO2 <- median(merged$NO2[merged$INCOME >= med_income], na.rm=T)
low_income_NO2 <- median(merged$NO2[merged$INCOME < med_income], na.rm=T)

# Output Graphs of pollution vs income and pollution vs white percent
incomeNO2 <- ggplot(merged) + geom_point(aes(x=INCOME, y=NO2, colour="NO2")) + geom_point(aes(x=INCOME, y=HCHO, colour="HCHO")) + scale_colour_manual(values=c("NO2"="black", "HCHO"="red"))
ggsave(incomeNO2, file=paste(folder, "pollutionVsIncome.png", sep="/"))

raceNO2 <- ggplot(merged) + geom_point(aes(x=WHITEPE, y=NO2, colour="NO2")) + geom_point(aes(x=WHITEPE, y=HCHO, colour="HCHO")) + scale_colour_manual(values=c("NO2"="black", "HCHO"="red"))
ggsave(raceNO2, file=paste(folder, "pollutionVsRace.png", sep="/"))

shp_outfile <- paste(folder, "combined_shapefile", sep="/")
dir.create(shp_outfile)

st_write(merged, paste(shp_outfile, "pollution_and_race.shp", sep="/"))