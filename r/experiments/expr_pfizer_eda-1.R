# Objective: Exploratory data analysis & Inferential Analysis
# OBJECTIVE: To ask relevant questions about the data, do some preliminary exploration, perform the necessary manipulations or aggregations, generate visualizations, and reach conclusions or insights.
# Challenge: Pfizer Healthcare Offline Assessment 
# Position applied for: Data Scientist & Engineer, Manufacturing - Chennai

# Script author: Ashish Dutt
# Email: drashishdutt@gmail.com
# Script Create Date: 18-Sept-2021
# Script Last Modified Date: 19-Sept-2021

# clean workspace
rm(list = ls())
# required libraries
library(tidyverse)
library(lubridate) # for date functions
library(GoodmanKruskal)

# read data in memory
df_ccs <- read.csv(file = "data/ccs.csv", sep = ",", na=c("",NA))
df_diag <- read.csv(file = "data/Diagnosis.csv", sep = ",", na=c("",NA))
df_pres <- read.csv(file = "data/Prescriptions.csv", sep = ",", na=c("",NA))
# lowercase all column names
names(df_ccs)<- tolower(names(df_ccs))
names(df_diag)<- tolower(names(df_diag))
names(df_pres)<- tolower(names(df_pres))

# rename column name
# variable `diag` in diagnosis file is same as variable `icd10` in ccs file
colnames(df_ccs)[ colnames(df_ccs) == 'diag']<- 'icd10'
# inner join dataframes
df_ccsdiag <- inner_join(x=df_diag, y=df_ccs, by="icd10")
df_final <- inner_join(x=df_ccsdiag, y= df_pres, by= "patient_id")
df<- df_final
# convert char dates to date
df$diag_date<- ymd(df$diag_date)
df$prescp_date<- ymd(df$prescription_date)
df$prescription_date<- NULL
# Filter and keep data for diags & prescrp year range 2015-2018
df_2k15 <- df %>%
  filter(prescp_date>= "2015-02-01")
# rearrange vars
df_2k15<- df_2k15[,c(1,3:7,9:11,2,8)]
# lowercase col values
df_2k15 = as.data.frame(sapply(df_2k15, tolower)) 
# convert char to date
df_2k15<- mutate_at(df_2k15, vars(ends_with("_date")), funs(ymd))
# split date into separate cols
df_2k15<- df_2k15 %>%
  mutate(pres_month = month(prescp_date),
         pres_day = day(prescp_date),
         pres_year = year(prescp_date))
df_2k15<- df_2k15 %>%
  mutate(diag_month = month(diag_date),
         diag_day = day(diag_date),
         diag_year = year(diag_date))
df_2k15$prescp_date<- NULL
df_2k15$diag_date<- NULL

# Solution A 
solution_A <- df_2k15 %>%
  count(patient_id, ccs_1_desc, ccs_2_desc) %>%
  arrange(desc(n)) %>%
  group_by(ccs_1_desc) 

patient_high_prescr_count <- df_2k15 %>%
  count(patient_id, drug_category) %>%
  arrange(desc(n)) %>%
  group_by(drug_category) %>%
  slice(seq_len(3))

high_pres_year <- df_2k15 %>%
  count(patient_id, pres_year) %>%
  arrange(desc(n))

## categorical data analysis

# significance test: chi-square test
chisq.test(df_2k15$ccs_1_desc, df_2k15$patient_id, correct = FALSE)
# Strength of association: Goodman kruskal tau test
varset1<- c("patient_id","ccs_1_desc")
df.1<- subset(df_2k15, select = varset1)
GKmatrix1<- GKtauDataframe(df.1)
plot(GKmatrix1, corrColors = "blue")

## END OF SCRIPT