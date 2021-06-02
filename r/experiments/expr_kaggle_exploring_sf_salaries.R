# Analysis objective: To explore the salary distribution
# Possible hypothesis to check are;
# 1. Salary depends on profession type

rm(list = ls())

# required libraries
library(tidyverse)

# Exploratory Data Analysis
df<- read_csv("data/kaggle_sfsalaries.csv", na = c("", NA))
dim(df) # 148654 rows 13 cols
sum(is.na(df)) # 446579 missing values
colSums(is.na(df)) # vars benefits, status, notes are completely blank. remove them from further analysis

# drop all blank cols
df$Id<- NULL
df$Notes<- NULL
df$Agency<- NULL # static with only 1 value

# Feature Engineering
job_type_legal<- 'police|fire|sheriff|attorney|lawyer|judge|auditor|inspector'
job_type_health<- 'nursing|nurse|physician|anethist|forensic|doctor'
job_type_manufc<- 'building|bricklayer|contract|architect|architecturalengineer|landscape|design|designer|technician'
job_type_admn<- 'adm|admin|administrative|administrator|clerk|assessor'
job_type_secur<- 'security|guard'
job_type_edu<- 'instructor'
job_type_animal<- 'animal|aquatics|aquatic'
job_type_ojt<- 'apprentice|intern'
# create new variables. Assign boolean value basis of other cols
df<- df %>%
  # lowercase all character variables
  mutate(across(where(is.character), tolower))%>%
  # create new logical colum from jobTitle type col
  mutate(job_lgl = str_detect(JobTitle, job_type_legal))%>%
  mutate(job_hlth = str_detect(JobTitle, job_type_health))%>%
  mutate(job_manuf = str_detect(JobTitle, job_type_manufc))%>%
  mutate(job_admin = str_detect(JobTitle, job_type_admn))%>%
  mutate(job_securty = str_detect(JobTitle, job_type_secur))%>%
  mutate(job_edu = str_detect(JobTitle, job_type_edu))%>%
  mutate(job_ojt = str_detect(JobTitle, job_type_ojt))

table(df$job_lgl)
table(df$job_admin)
table(df$job_securty)
table(df$job_ojt)
