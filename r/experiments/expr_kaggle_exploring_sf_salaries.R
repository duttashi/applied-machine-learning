# Analysis objective: To explore the salary distribution
# Possible hypothesis to check are;
# 1. Salary depends on profession type


# required libraries
library(tidyverse)
rm(list = ls())
# Exploratory Data Analysis
df<- read_csv("data/kaggle_sfsalaries.csv", na = c("", NA))
dim(df) # 148654 rows 13 cols
sum(is.na(df)) # 446579 missing values
colSums(is.na(df)) # vars benefits, status, notes are completely blank. remove them from further analysis

# drop all blank cols
df$Id<- NULL
df$Benefits<- NULL
df$Notes<- NULL
df$Status<- NULL

# Feature Engineering
job_legal_type<- 'police|fire|sheriff|attorney|lawyer|judge'
job_health_type<- 'nursing|nurse|physician|anethist|forensic|doctor'
df<- df %>%
  # lowercase all character variables
  mutate(across(where(is.character), tolower))%>%
  # create new logical colum from jobTitle type col
  mutate(job_lgl = str_detect(JobTitle, job_legal_type))%>%
  mutate(job_hlth = str_detect(JobTitle, job_health_type))
