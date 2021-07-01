# data souce: https://www.kaggle.com/nicholasjhana/energy-consumption-generation-prices-and-weather

# clean workspace
rm(list = ls())

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

## convert date, time from character to date, time format
str(df_enrgy$date)
str(df_enrgy$time)
df_enrgy$date<- lubridate::ymd(df_enrgy$date)
df_enrgy$time<- lubridate::hms(df_enrgy$time)

str(df_enrgy)
# df_enrgy<- tidyr::separate(df_enrgy, date, c("year","month","date"), sep = "-")
# df_enrgy<- tidyr::separate(df_enrgy, time, c("hour","min","sec"), sep = ":")

## Remove blank variables/columns
df_enrgy$generation.hydro.pumped.storage.aggregated<- NULL
df_enrgy$forecast.wind.offshore.eday.ahead<- NULL
sum(is.na(df_enrgy)) # 401 missing values
## Remove all missing values
df_enrgy<- df_enrgy %>%
  na.exclude()
sum(is.na(df_enrgy))
sum(is.na(df_weather)) # 0 missing values

## convert all character cols to numeric
# df_enrgy[] <- lapply(df_enrgy, function(x) as.numeric(as.character(x)))

## For weather data, split time col into date & time
df_weather$dt_iso<- as.POSIXct(df_weather$dt_iso)
df_weather<- tidyr::separate(df_weather, dt_iso, c("date", "time"), sep = " ")

## convert date, time from character to date, time format
str(df_weather$date)
str(df_weather$time)
df_weather$date<- lubridate::ymd(df_weather$date)
df_weather$time<- lubridate::hms(df_weather$time)

## convert date, time to date format

# df_weather<- tidyr::separate(df_weather, date, c("year","month","date"), sep = "-")
# df_weather<- tidyr::separate(df_weather, time, c("hour","min","sec"), sep = ":")

# join energy table & weather table on date and time cols
str(df_enrgy)
str(df_weather)

df_final <- left_join(df_enrgy, df_weather, 
                      by=c("date"="date","time"="time")
                      )
head(df_final$price.actual)
head(df_final$price.day.ahead)
