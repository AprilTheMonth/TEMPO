# #!/usr/bin/env python

# # Load packages into current runtime
import datetime as dt
import geopandas as gpd

import subprocess
import cmr
import wget
import os
import sys

# Import Libraries
import pyrsig
import pandas as pd
import pycno
import getpass
import matplotlib.pyplot as plt
from collections import defaultdict
import re
from thefuzz import process, fuzz
from dotenv import load_dotenv

if(len(sys.argv) < 5):
    raise Exception("usage:\n\t./pollution_analysis.py [city] [state] [start_date] [end_date]")

load_dotenv()
if (os.environ.get("census_API") is None):
    raise Exception("Please Request a key at https://api.census.gov/data/key_signup.html and put it in a .env file")

city_query = sys.argv[1]
state_query = sys.argv[2]
start_date = sys.argv[3]
end_date = sys.argv[4]


# # Get United States urban areas shapefile
# # This is written to be used on a linux machine, might not work on mac
if(not os.path.isdir("city_shapefile")):
    os.makedirs("city_shapefile")
    wget.download("https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_ua10_500k.zip", out="./city_shapefile")
    os.system("unzip city_shapefile/* -d ./city_shapefile")
    os.system("rm city_shapefile/*.zip")

gdf_cities = gpd.read_file("city_shapefile/")

#  Verify the cities were loaded correctly
city_names = gdf_cities['NAME10']


# Populates a dictionary that converts a states two-letter post code into a fips code
postal_to_fips = dict()
with open("fips.txt", "r") as file:
    for line in file:
        # Uses list comprehension to only get the entries that are 2 uppercase letters
        line = [s for s in re.split("\t| ", line[:-1]) if len(s) == 2 and s.upper() == s]
        postal_to_fips[line[0]] = line[1]

#print(postal_to_fips)
# Uses fuzzy pattern matching to try to best approximate the city the user wants to laod
# Works pretty well, but some cities are annoying syntactically
# (e.g "washington dc" outputs "washington nc," you have to put "washington d.c")
def get_best_match(cityString: str, stateString: str) -> str:
    cityString = cityString[0].upper() + cityString[1:]
    city_collection = defaultdict(list)
    # Create a dictionary of the form "State -> list of all cities with a city of that name"
    for s in city_names:
        for state in s.split(",")[1][1:].split("--"):
            city_collection[state].append(s)
    
    #print(city_collection.keys())
    best_match = None
    best_match_ratio = 60
    for metro_area in city_collection[stateString.upper()]:
        for city in metro_area.split(",")[0].split("--"):
            ratio = fuzz.partial_ratio(city, cityString.lower())
            if ratio > best_match_ratio:
                best_match = metro_area
                best_match_ratio = ratio
                
    if best_match:
        return best_match
    else:
        raise Exception("Invalid City Identifier")

city_name = get_best_match(city_query, state_query)
print("Getting data for ", city_name)

if not os.path.isdir("tracts_shapefile"):
    os.makedirs("tracts_shapefile")

# Cities that cross multiple state lines are seperated by multiple dashes
# e.g Seattle OR--WA
state = city_name.split(", ")[1]
census_tracts = gpd.GeoDataFrame()
for s in state.split("--"):
    # For each state in the city, extract the fips code (a two-digit number used to identify each US state and territory)
    fips_code = postal_to_fips[s]
    # Use string formatting to automatically download census tract shapefiles for each relevant state
    if not os.path.isdir(f"tracts_shapefile/{s}"):
        os.makedirs(f"tracts_shapefile/{s}")
        wget.download(f"https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_{fips_code}_tract_500k.zip", out=f"./tracts_shapefile/{s}")
    if census_tracts.empty:
        census_tracts = gpd.read_file(f"./tracts_shapefile/{s}/cb_2018_{fips_code}_tract_500k.zip")
    else:
        new_tracts = gpd.read_file(f"./tracts_shapefile/{s}/cb_2018_{fips_code}_tract_500k.zip")
        census_tracts = pd.concat([census_tracts, new_tracts])

# Extract the shapefile for the urban area from the earlier shapefile
city = gdf_cities[gdf_cities["NAME10"] == city_name]
# Get the intersection of the census tracts shapefile and the urban area shapefile
intersection = census_tracts.overlay(city, how="intersection")
   
os.makedirs(city_name, exist_ok=True)
os.makedirs(f"{city_name}/tracts", exist_ok=True)
intersection.to_file(f"{city_name}/tracts/city_with_tracts.shp")


def get_NASA_files(start_date, end_date):
    products = ['tempo.l2.no2.vertical_column_troposphere', 'tempo.l2.hcho.vertical_column']
    city = gdf_cities[gdf_cities["NAME10"] == city_name]
    # Get the bounding box of the urban area
    bbox = city.bounds

    bbox = bbox.values[0]

    bbox = city.bounds

    bbox = bbox.values[0]
    bbox
    center_x = ((bbox[0] + bbox[2]) / 2)
    start_time = 11
    start_time -= center_x / 15
    start_minute = ((start_time % 1) * 60) // 1
    start_hour = start_time // 1
    end_hour = start_hour+3

    # Compare over various seasons
    start1day = pd.to_datetime(f'{start_date} ' + str(start_hour) + ':' + str(start_minute), utc=True)
    end1day = pd.to_datetime(f'{start_date} ' + str(end_hour) + ':' + str(start_minute), utc=True)

    endrange = pd.to_datetime(f'{end_date} ' + str(end_hour) + ':' + str(start_minute), utc=True)
    os.makedirs(f"{city_name}/TEMPO", exist_ok=True)

    total = 0
    errors = 0
    while (start1day < endrange):
        # Download the TEMPO data from the selected dates, over the selected area
        # Need to use overwrite = true because the tempo api will re-use files with incomplete data
        total += 2
        #print(start1day.tzinfo)
        #print(end1day)
        api = pyrsig.RsigApi(bdate=start1day, edate=end1day, bbox=bbox, overwrite = True, workdir=f"{city_name}/TEMPO")
        api_key = 'anonymous'  # using public data, so using anonymous TODO: Determine limits of public data
        api.tempo_kw['api_key'] = api_key
        # Convert to a data frame
        for product in products:
            try:
                api.to_netcdf(product, removegz=True)
            except:
                errors += 1
                pass

        
        start1day += pd.Timedelta(days=1)
        end1day += pd.Timedelta(days=1)

get_NASA_files(start_date, end_date)

# Convert the netcdf files to rdata
os.system(f"Rscript make_rdata.r \"{city_name}\"")

# Fetch census data for the given city
os.system(f"Rscript census_data.r \"{city_name}\"")

# Turn the pollution data into simple features objects
os.system(f"Rscript process_pollution_data.r \"{city_name}\"")

# Combine the pollution data and the demographic data 
os.system(f"Rscript combine_data.r \"{city_name}\"") 