library(dplyr) # for data manipulation
library(readr) # for read_csv()
library(magrittr) # for %>% operator
library(forcats) # for fct_collapse()
library(tidyr) # separate()

# read the data
df<- read_csv(file = "data/water_point_data_exchange_india.csv",
              na=c("",NA)) 

# Exploratory data analysis

## Data Management
colnames(df)
# Observation: rename all column names begining with a # symbol
names(df)<- gsub("#","",names(df))
# Observation: coerce all character cols to factor
df<- df %>%
  mutate_if(sapply(df, is.character), as.factor)
df$water_source<- fct_collapse(df$water_source, "Unprotected Tube Well"= c("Unprotected Tube Well",
                                                                           "Unprotected/Unlined Well",
                                                                           "Unrotected Tube Well"))
df$water_tech_clean<- fct_collapse(df$water_tech_clean, "Hand Pump"= c("Hand Pump - India Mark","Hand Pump"))
df$water_tech<- fct_collapse(df$water_tech, "NA" = "null")
df$management<- fct_collapse(df$management, "NA" = "Don't Kw",
                             "community_mgmt"= "Community Management",
                             "govt_mgmt"= c("Government Operation","Institutional Management"),
                             "private_mgmt"= "Private Operator/Delegated Management")

df$status<- fct_collapse(df$status, "not_functional" = "Does Not Function")
# split report_date into three vars: report_day, report_month, report_year
df<- df %>%
  separate(report_date, into = c("report_month","report_day","report_year"),
           sep = "/")
df<- df %>%
  separate(report_year, into = c("report_year","report_time"),
           sep = " ")
df<- df %>%
  separate(report_time, into = c("report_hour","report_min","report_sec"),
           sep = ":")
# drop cols
df$row_id<-NULL
df$source<-NULL
df$activity_id<-NULL
df$photo_lnk<-NULL
df$data_lnk<-NULL
df$public_data_source<-NULL
df$country_id<-NULL
df$pay<-NULL
df$report_min<-NULL
df$report_sec<-NULL

# write clean data to disk
write_csv(df, file = "data/WPEIndia_clean.csv")

