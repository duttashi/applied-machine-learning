# data souce: https://www.kaggle.com/nicholasjhana/energy-consumption-generation-prices-and-weather


library(tidyverse)

# load data

df_enrgy<- read.csv("data/kaggle_energy_dataset.csv")
df_weather<- read.csv("data/kaggle_weather_features.csv")

# EDA
dim(df_enrgy) # [1] 35064    29
dim(df_weather) # [1] 178396     17

sum(is.na(df_enrgy)) # 70529 missing values
colSums(is.na(df_enrgy)) # variable "generation.hydro.pumped.storage.aggregated" and "forecast.wind.offshore.eday.ahead" are totally blank. drop it

# Data Management decisions
str(df_enrgy)

## split time col into date & time
df_enrgy$time<- as.POSIXct(df_enrgy$time)
df_enrgy<- tidyr::separate(df_enrgy, time, c("date", "time"), sep = " ")
df_enrgy<- tidyr::separate(df_enrgy, date, c("year","month","date"), sep = "-")
df_enrgy<- tidyr::separate(df_enrgy, time, c("hour","min","sec"), sep = ":")

## Remove blank variables/columns
df_enrgy$generation.hydro.pumped.storage.aggregated<- NULL
df_enrgy$forecast.wind.offshore.eday.ahead<- NULL
sum(is.na(df_enrgy)) # 401 missing values
## Remove all missing values
df_enrgy<- df_enrgy %>%
  na.exclude()
sum(is.na(df_enrgy))
sum(is.na(df_weather)) # 0 missing values

