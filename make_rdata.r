# Install uninstalled packages
list.of.packages <- c("data.table", "ncdf4", "R.utils", "stringr", "raster")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(ncdf4)
library(data.table)
library(raster)
library(stringr)

# Fetch command line arguments
args <- commandArgs(TRUE)
folder <- args[1]

# Default to Rochester, NY
if (is.na(folder)) {
  folder <- "Rochester, NY"
}

# Use UTC, as RLang defualts to local time
Sys.setenv(TZ="UTC")

# Get all files fetched from the python notebook
filesno2 = list.files(folder, pattern="*no2.*[.]nc", full.names=TRUE, recursive=TRUE)
fileshcho = list.files(folder, pattern="*hcho.*[.]nc", full.names=TRUE, recursive=TRUE)
dir.create(paste(folder, "RData", sep="/"))

# Loop through each file, and create a data table
for ( f in seq_along(filesno2) ) {


  fin = filesno2[f]
  id = nc_open(fin)

  # TODO: make this resilient to the possibility of NO2 and HCHO files stored in different orders
  finhcho = fileshcho[f]
  idhcho = nc_open(finhcho)

  file_name_no_path <- str_split_i(fin, "/", 3)
  outfile <- sprintf("%s/RData/%s.RData", folder, substr(file_name_no_path, 1, nchar(file_name_no_path)-3))


  if ( ! file.exists(outfile) ) {

      # Get relevant data from the netcdf files
      lon <- as.vector(ncvar_get(id,"longitude"))
      lat <- as.vector(ncvar_get(id,"latitude"))
      no2 <- as.vector(ncvar_get(id, "no2_vertical_column_troposphere"))
      time <- as.vector(ncvar_get(id, "hhmmss"))

      sw <- as.vector(ncvar_get(id, "Longitude_SW"))
      se <- as.vector(ncvar_get(id, "Longitude_SE"))
      nw <- as.vector(ncvar_get(id, "Longitude_NW"))
      ne <- as.vector(ncvar_get(id, "Longitude_NE"))
      lon_bounds <- cbind(sw, nw, ne, se)

      sw <- as.vector(ncvar_get(id, "Latitude_SW"))
      se <- as.vector(ncvar_get(id, "Latitude_SE"))
      nw <- as.vector(ncvar_get(id, "Latitude_NW"))
      ne <- as.vector(ncvar_get(id, "Latitude_NE"))
      lat_bounds <- cbind(sw, nw, ne, se)

      lonhcho <- as.vector(ncvar_get(idhcho,"longitude"))
      lathcho <- as.vector(ncvar_get(idhcho,"latitude"))
      hcho <- as.vector(ncvar_get(idhcho,"vertical_column"))

      data <- data.table(longitude = lon, longitude_bb = apply(lon_bounds,1,as.list), latitude = lat, latitude_bb = apply(lat_bounds,1,as.list), no2 = no2, local_time = time)
      datahcho <- data.table(longitude = lonhcho, latitude = lathcho, hcho = hcho)

      # Combine no2 and hcho data spatially
      data <- merge(data, datahcho)


      save(data, file=outfile)

  }

  nc_close(id)

}