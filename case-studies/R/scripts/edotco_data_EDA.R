getwd()
#setwd("C:/Users/Ashoo/Documents/R playground/data hack")

# clean the workspace
rm(list=ls())

# required libraries
library(data.table) # for fread()
library(Amelia) # for missmap()
library(ggplot2)
library(magrittr) # for %>% (pipe)
library(tidyr) # for drop_na()

# Note: A preliminary investigation shows that missing data is represented either as NA or blanks.
# Replace blanks with NA when reading the data in-memory
dlyEnrgy.dat <-fread('edotco/data/fact_operations_dailyenergy_31Oct19.csv'
                     ,na.strings=c("", "NA"),header = TRUE, sep = ",")
equip.dat <- fread('edotco/data/equip_TT_Oct19.csv',na.strings=c("", "NA"),header = TRUE, sep = ",")
grid.dat <- fread('edotco/data/Grid_DC_2G_3G Oct19.csv', na.strings=c("", "NA"),header = TRUE, sep = ",")   
site_info.dat <- fread('edotco/data/site_information.csv',na.strings=c("", "NA"),header = TRUE, sep = ",")
site_info_oe.dat <- fread('edotco/data/site_information_oe.csv', na.strings=c("", "NA"),header = TRUE, sep = ",")

##### Exploratory Data Analysis

# 1. Data dimensions
dim(dailyEnrgy.dat) # [1] 285639    100
dim(equip.dat)
dim(grid.dat)
dim(site_info.dat)
dim(site_info_oe.dat)

# 2. Missing data
sum(is.na(dailyEnrgy.dat)) # [1] 27709959
sum(is.na(equip.dat)) # 32
sum(is.na(grid.dat)) # [1] 50985
sum(is.na(site_info.dat)) # [1] 396724
sum(is.na(site_info_oe.dat)) # [1] 135183

# Visualize missing data
missmap(dailyEnrgy.dat, main = "Missing data plot for daily energy")
missmap(equip.dat, main = "Missing data plot for equipments")
missmap(grid.dat, main = "Missing data plot for grids")
missmap(site_info.dat, main = "Missing data plot for site info")
missmap(site_info_oe.dat, main = "Missing data plot for site info oe")
## Observations
# 1. 97% data missing for daily energy
# 2. 8% data missing for equipment
# 3. 26% data missing for grids
# 4. 23% data missing for site-info
# 5. 28% data missing for site-info-oe

# Missing data treatment

## Method # 1: remove all missing data. 
  # This infers that we are discrading information. 
  # Also, if this approach is followed, then dataframes like daily_energy_data, grid data, site_info and site_info_oe data will be dropped.
# Note: When more than 50% data is missing from a dataframe, then its best to remove such data. Data Imputation is not applicable in here
# Drop columns for dailyEnergy.dat where missing values are greater than 70%
equip.cmplt <- equip.dat %>%
  drop_na()
grid.cmplt <- grid.dat %>%
  drop_na()
site_info.cmplt <- site_info.dat %>%
  drop_na()
site_info_oe.cmplt <- site_info_oe.dat %>%
  drop_na()
dlyEnrgy.cmplt <- dlyEnrgy.dat %>%
  drop_na()

## Method # 2: Missing data imputation



# make a copy 
df<- dailyEnergy.dat
dim(df) # [1] 285639    100
sum(is.na(df)) # [1] 16382747 values are missing
colSums(is.na(df))

# missing data visualization
#install.packages('Amelia', dependencies = TRUE)

missmap(df)

# A function that plots missingness
# requires `reshape2`

library(reshape2)
library(ggplot2)

ggplot_missing <- function(x){
  
  x %>% 
    is.na %>%
    melt %>%
    ggplot(data = .,
           aes(x = 'dim_activity_date_key',
               y = 't1_avg_load_a')) +
    geom_raster(aes(fill = value)) +
    scale_fill_grey(name = "",
                    labels = c("Present","Missing")) +
    theme_minimal() + 
    theme(axis.text.x  = element_text(angle=45, vjust=0.5)) + 
    labs(x = "Variables in Dataset",
         y = "Rows / observations")
}
#Let’s test it out
ggplot_missing(df)


(285639-276069)/100 
# 95% data is missing for columns 
dim_activity_date_key, 
dim_site_information_o_key,
dim_ntc_key,
t1_avg_load_a,
t1_max_load_a
t1_usage_kwh
t2_avg_load_a
t2_max_load_a
t2_usage_kwh
t3_avg_load_a
t3_max_load_a
t3_usage_kwh
t5_avg_load_a 
t6_avg_load_a
t7_avg_load_a
t7_max_load_a
t7_usage_kwh

apply(dailyEnergy.dat, MARGIN = 1, function(x) sum(is.na(x)))

# count missing data row and column-wise
# Now generate vectors of the counts
df<- dailyEnergy.dat
miscols.count <- colSums(is.na(df))
x<-names(df[miscols.count])
x
sum(is.na(df))
colSums(is.na(df))
miscol<- names(colSums(is.na(df)))
miscol
