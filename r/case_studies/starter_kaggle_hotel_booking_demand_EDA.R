# Have you ever wondered when the best time of year to book a hotel room is? Or the optimal length of stay in order to get the best daily rate? What if you wanted to predict whether or not a hotel was likely to receive a disproportionately high number of special requests?
# This hotel booking dataset can help you explore those questions!
# data source: https://www.kaggle.com/jessemostipak/hotel-booking-demand

# clean the workspace
rm(list = ls())
# load required libraries
library(tidyverse) 
library(caret) 

# load data
getwd()
data_train<- read.csv("data/hotel_bookings.csv", header = TRUE,sep = ",")
dim(data_train)

# initial observations
str(data_train)
## convert variable reservation_status_date to date and split into separate cols
## convert variable arrival_date_month to int
## separate data based on hotel which got only 2 levels

# make a copy of the data
df<- data_train

# Data cleaning
# convert date from categorical to Date format
df$reservation_status_date <- as.Date(df$reservation_status_date, format = "%Y-%m-%d")
# separate date into year, month, day format
df<- df %>%
  separate(reservation_status_date, c("resv_year", "resv_month", "resv_day"), sep = "-")
# coerce Year, Month, Day from character to int
df$resv_year<- as.integer(df$resv_year)
df$resv_month<- as.integer(df$resv_month)
df$resv_day<- as.integer(df$resv_day)
df$arrival_date_month<- as.integer(df$arrival_date_month)
table(df$resv_year)

# remove agent and company from analysis
df$agent<- NULL
df$company<- NULL

# check data structure
str(df)
table(df$reserved_room_type)
table(df$assigned_room_type) # whats the difference between reserved room type & assigned room type?
# no major difference. So merge these two vars
df$room_type<- union(levels(df$reserved_room_type), levels(df$assigned_room_type))
