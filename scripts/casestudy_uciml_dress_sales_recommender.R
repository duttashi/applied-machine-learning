# data source url: https://archive.ics.uci.edu/ml/datasets/Dresses_Attribute_Sales
# objective: Exploratory Data Analysis

# clean the workspace
rm(list = ls())

# load required libraries
library(tidyverse)
# Get the Data
dress_data <- data.frame(read_csv(file = "data/uciml_dress_attribute.csv",na=c("null",NA)))
str(dress_data)

# EDA
sum(is.na(dress_data)) # 821 
colSums(is.na(dress_data)) 

# Preliminary observations
# 821 missing values. # Max missing values in vars FabricType, Decoration, Pattern.Type, waiseline, material
# rename the column names to lower case. 
# rename var waiseline to waistline
# rename var Pattern.Type to patterntype

# rename col names and save to new data frame
df<-dress_data %>%
  rename(dressid=Dress_ID, style=Style, price=Price, rating=Rating, 
         size=Size,season=Season, neckline = NeckLine, sleevelength = SleeveLength,
         waistline = waiseline, material = Material, fabrictype=FabricType,
         decoration = Decoration, patterntype=Pattern.Type, recommendation=Recommendation)

# coerce all character vars to factor type
df<-df %>%
  #str()
  mutate_if(is.character, as.factor)
# check that all factor levels are complete ie have value associate to the level
colSums(is.na(df))
levels(df$patterntype) # missing level name coded as ""
levels(df$price) # missing level name coded as ""
levels(df$season) # missing level name coded as ""
levels(df$neckline) # missing level name coded as ""
levels(df$waistline) # missing level name coded as ""
levels(df$material) # missing level name coded as ""
levels(df$fabrictype) # missing level name coded as ""
levels(df$decoration) # missing level name coded as ""
levels(df$patterntype)# missing level name coded as ""

## recode the factor levels 
str(df)
levels(df$style)
df$style <- fct_collapse(df$style,
                         'casual'=c("bohemian","Brief","Casual","cute","fashion",
                                    "Flare","Novelty","OL","party","sexy","Sexy")
                         )
levels(df$price)
df$price <- fct_collapse(df$price,
                         'high'=c("High","high","very-high"),
                         'low' = c("low","Low"),
                         'medium'=c('Medium','Average'),
                         "NA"="")
levels(df$size)                                  
df$size <- fct_collapse(df$size, 
                                  'S'=c('s','S','small')
                                  )
levels(df$season)
df$season <- fct_collapse(df$season, 
                                 'autumn'=c('Automn',"Autumn"), 'spring'='Spring', 'summer'='Summer',
                                 'winter'='Winter', "NA"=""
                                 )
levels(df$neckline)
# reference: https://www.pinterest.com/pin/489766528200439406/
df$neckline<- fct_collapse(df$neckline,
                           'NA'=c('','NULL'),'bowneck'=c('boat-neck','bowneck'),
                           'collar'=c('mandarin-collor','turndowncollor','mandarin-collor','sqare-collor','peterpan-collor'),
                           'sweetheart'=c('sweetheart','Sweetheart'),
                           'v-neck'=c('o-neck','v-neck','slash-neck')
                           )
levels(df$sleevelength)
df$sleevelength<- fct_collapse(df$sleevelength,
                               "halfsleeve"=c("cap-sleeves","capsleeves","half","halfsleeve",
                                              "Petal","short","sleeevless","sleeevless","sleveless",
                                              "threequarter","threequater","thressqatar",
                                              "turndowncollor","urndowncollor"),
                               "NA"="NULL", "fullsleeve"="full")

df$waistline<- fct_collapse(df$waistline,"NA"="")
str(df)
levels(df$material)
df$material<- fct_collapse(df$material, "NA"="", "silk"=c("milksilk","silk","sill"),
                           "others"=c("other","modal","model"))
# plots
df %>%
  group_by(neckline)%>%
  filter(!is.na(neckline))%>%
  ggplot(aes(x=neckline, y=rating))+
  geom_boxplot()
# the var price, size has several overlapping levels. restructure it
