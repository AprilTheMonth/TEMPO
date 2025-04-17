
# Install any uninstalled packages
list.of.packages <- c("sf", "tidyverse", "tidycensus", "ggplot2", "viridis", "sys")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(tidycensus)
library(tidyverse)
library(sf)
library(ggplot2)
library(viridis)
library(sys)

# Fetch command lines arguments
args <- commandArgs(TRUE)
folder <- args[1]

# If no command line arguments specified, default to Rochester
# If file is run from main, this shouldn't happne
if (is.na(folder)) {
  folder <- "Rochester, NY"
}

# Get the census API key from the environment file
readRenviron(".env")
census_api_key(Sys.getenv("census_API"))


file_location <- paste(folder, "tracts/city_with_tracts.shp", sep="/")

# Variable name is outdated, just stores the queried city
rochester <- read_sf(file_location)

# Query all states for those cities that span state lines
statefp <- unique(rochester$STATEFP)

df <- data.frame(row.names = c("GEOID", "NAME", "INCOME", "WHITEPERCENT"))
names <- c()
geoids <- c()
totalpop <- c()
whitepop <- c()

# For each state, request the census-tract level demographic data
for (state in statefp){
  query_results <- get_acs(geography = "tract",
                           year = 2023,
                           state = state,
                           # These variables are the census API values for the relevant data
                           variables = c(whitePop = "B03002_003", totalPop = "B03002_001", income = "B19013_001"))
  
  NAME <- query_results$NAME[c(T, F, F)]
  GEOID <- query_results$GEOID[c(T, F, F)]
  totalpop <- query_results$estimate[c(T,F,F)]
  whitepop <- query_results$estimate[c(F,T,F)]
  INCOME <- query_results$estimate[c(F, F, T)]
  WHITEPERCENT <- whitepop / totalpop
  df <- rbind(df, data.frame(NAME, GEOID, INCOME, WHITEPERCENT))
}

# Merge the shapefile data with the census data by geoid
merged <- merge(rochester, df, by="GEOID", all.x=T)

# Save relevant data & Create relevant plots
g1 <- ggplot(merged) + geom_sf(aes(fill = WHITEPERCENT)) + scale_fill_viridis_c()
g2 <- ggplot(merged) + geom_sf(aes(fill = INCOME)) + scale_fill_viridis_c()

shp_outfile <- paste(folder, "demographics_shapefile", sep="/")
dir.create(shp_outfile)

st_write(merged, paste(shp_outfile, "demographics.shp", sep="/"))

ggsave(g1, file=paste(folder, "whitepercent.png", sep="/"))
ggsave(g2, file=paste(folder, "income.png", sep="/"))