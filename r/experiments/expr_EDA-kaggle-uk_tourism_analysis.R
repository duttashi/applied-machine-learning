# Analysis objective: Exploratory data analysis

rm(list = ls())

# required libraries
library(tidyverse)

# Exploratory Data Analysis
df<- read.csv("data/kaggle_uk_tourism_info.csv",
              stringsAsFactors = TRUE)
str(df)
colnames(df)
# lowercase all vars
df<-df %>%
  # lowercase all character variables
  mutate(across(where(is.integer), tolower))
colnames(df)

# split the title col
view(df$Title)
df<- df %>%
  separate(Title, into = c("Year","Month"))

# rename column names
# df <- df %>%
#   rename(replace = 
#            c("OS_vstr_min_earng"="OS visitors Earnings: Mn £ (NSA)")
#          )

colnames(df)
names(df)[names(df)=="OS.visitors.Earnings..Mn....NSA."]<- "NSAOS_vstr_minearn" 
names(df)[names(df)=="OS.visitors.Earnings..Mn....SA."]<- "SAOS_vstr_minearn" 
names(df)[names(df)=="OS.visitors....in.Thousands..NSA."]<- "NSAOS_vstr_thsnd" 
names(df)[names(df)=="OS.visitors....in.Thousands.SA."]<- "SAOS_vstr_thsnd" 
names(df)[names(df)=="UK.visitors.Expenditure..Mn....NSA."]<- "NSAUK_vist_min_expnd" 
names(df)[names(df)=="UK.visitors.Expenditure..Mn....SA."]<- "SAUK_vist_min_expnd" 
names(df)[names(df)=="UK.visitors....in.Thousands..NSA."]<- "NSAUK_vist_thsnd" 
names(df)[names(df)=="UK.visitors....in.Thousands..SA."]<- "SAUK_vist_thsnd"
colnames(df)

# multiple boxplots in one page
library(reshape2)
df_new <- melt(df, id.vars = "Year") 
?melt

ggplot(data = df)+
  geom_boxplot(aes(y=factor(Month), x="SAUK_vist_min_expnd",
                   fill=factor(Month)),position=position_dodge(1))+
  theme_minimal()
colnames(df)

ggplot(data = df, aes(factor(Year), NSAOS_vstr_minearn
                      , group=Month))+
  geom_boxplot()
table(df$Year)
