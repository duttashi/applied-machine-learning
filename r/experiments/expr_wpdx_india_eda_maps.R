library(readr)
library(leaflet)
library(dplyr)
library(magrittr) # for pipe 
library(tidyr) # for drop_na()

# Set value for the minZoom and maxZoom settings.
leaflet(options = leafletOptions(minZoom = 0, maxZoom = 18))

# read data
df<- read_csv(file = "data/WPEIndia_clean.csv")
colSums(is.na(df)) # the lat lon cols are non-empty
colnames(df)

table(df$water_source_clean)

# take a random sample of 50 rows
df_smpl<- df %>%
  drop_na() %>%
  sample_n(100)
sum(is.na(df_smpl))

View(df_smpl)
m<- leaflet(df_smpl) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~lon_deg, lat = ~lat_deg,
                   popup = ~water_source)
m
