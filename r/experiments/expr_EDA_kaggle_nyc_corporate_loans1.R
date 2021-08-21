# clean workspace
rm(list = ls())

library(tidyverse)
library(lubridate)
library(stringr) # for str_wrap()
library(caret)
library(moments) # for skewness() function

# read data
df<- read_csv("data/kaggle_nyc_loans.csv",na=c("",NA))
# Data preprocessing
# lowercase variable name & rename them
colnames(df)<- tolower(colnames(df))
# rename columns by replacing space with dot
df <- df %>%
  rename_all(list(~make.names(.)))
# split date into day, month, year cols
df<-df %>%
  mutate(
    fisclYrEndDate = mdy(fiscal.year.end.date),
    fsYrEnd_month = month(fisclYrEndDate),
    fsYrEnd_day = day(fisclYrEndDate),
    fsYrEnd_year = year(fisclYrEndDate)
  )

df<-df %>%
  mutate(loan_award_date = mdy(date.loan.awarded),
         loanaward_month = month(loan_award_date),
         loanaward_day = day(loan_award_date),
         loanaward_year = year(loan_award_date)
  )
# change month number to month name
df$loanaward_month<- month.name[df$loanaward_month]
df$fsYrEnd_month<- month.name[df$fsYrEnd_month]

# drop column
df$loan_award_date<- NULL
df$date.loan.awarded<- NULL
df$fiscal.year.end.date<- NULL
df$fisclYrEndDate<- NULL
df$fiscal.year.end.date<- NULL
# drop loans column because it has only 1 value "No" and rest values are blank
df$loans<-NULL

# filter columns with missing data
df<- df %>%
  filter(!is.na(df[,c(2:21)])) 
df<- df %>%
  filter(!is.na(df[, c(5:6)]))
df<- df %>%
  filter(!is.na(df[,c(13:14)]))
df<- df %>%
  filter(!is.na(df[,c(14)]))
# Revalue Factor Levels for categorical variables
# It's observed in this dataset, few categorical variables such as `authority name, loan purpose` consist of very long factor names. These will pose a problem in data visualization.
loan_purpose_new_levels<- c("startup","build commercial property", 
                            "education","buy equipment",
                            "build residential property","buy land",
                            "restoration","recruitment")
df$loan.purpose<- as.factor(df$loan.purpose)
loan_purpose_existing_levels<- levels(df$loan.purpose)  
names(loan_purpose_existing_levels)<- loan_purpose_new_levels
# now using mutate and fct_recode to recode the factor levels
df <- df %>%
  mutate(loan_purpose = fct_recode(loan.purpose, !!!loan_purpose_existing_levels))
levels(df$loan_purpose)
# drop original variable
df$loan.purpose<- NULL
# lets wrap the text to no more than 10 spaces
df$loan_purpose<- str_wrap(df$loan_purpose, width = 4)

# change datatype
df$recipient.postal.code<- as.character(df$recipient.postal.code)
df$fsYrEnd_month<- as.character(df$fsYrEnd_month)
df$fsYrEnd_year<- as.character(df$fsYrEnd_year)
df$loanaward_month<- as.character(df$loanaward_month)
df$loanaward_year<- as.character(df$loanaward_year)
df$interest.rate<- as.character(df$interest.rate)
df$fsYrEnd_day<- as.character(df$fsYrEnd_day)
df$loanaward_day<- as.character(df$loanaward_day)
df$jobs.created<- as.character(df$jobs.created)
df$jobs.planned<- as.character(df$jobs.planned)
df$new.jobs<- as.character(df$new.jobs)

# separate categorical & continuous variables
# use sapply()
df.cat<-df[,sapply(df, is.character)]
df.cont<-df[,!sapply(df, is.character)]
df.1<- df[,c(colnames(df.cat),colnames(df.cont))]

# Skewness treatment
# As all continuous variables are right/positively skewed, transformations can be square root, cube root and logarithms
# Applying logarithmic approach to reduce skewness
df.1$original.loan.amount<- log10(df.1$original.loan.amount)
df.1$loan.length<- log10(df.1$loan.length)
df.1$amount.repaid<- log10(df.1$amount.repaid)

# filter rows where amount.repaid & loan.length is less than equal to zero
df.1<- df.1 %>%
  filter(amount.repaid>0 & loan.length>0)
# filter data for NY state and remove the recipient.state variable
df.1 <- df.1 %>%
  filter(recipient.state=='NY')
df.1$recipient.state<- NULL

# CHECK FOR NEAR ZERO VARIANCE COLS
# Q. How many columns with near zero variance property?
badCols<- nearZeroVar(df.1)
dim(df.1[,badCols]) # [1] 5684 2
names(df.1[,badCols]) # [1] "new.jobs"      "fsYrEnd_month" "fsYrEnd_day"       "isFunded"     "isCollection" "paymt_min"    "paymt_sec"    "principal"
# remove the near zero variance predictors
df.1<- df.1[, -badCols]
dim(df.1) #[1] 5223 17

## Predictive Modeling
## Recode character variables to nominal
df.1<- df.1 %>%
  mutate(across(authority.name:loan_purpose,~as.factor(.))) %>%
  mutate(across(authority.name:loan_purpose,~factor(.,levels = unique(.)))) %>%
  mutate(across(authority.name:loan_purpose,~as.numeric(.)))

colnames(df.1)
## Assume ``loan.fund.sources` is the response variable `
ggplot(data = df.1, aes(x=loan.fund.sources))+
  geom_bar()+
  theme_bw()

df.2<- df.1 # make copy
# Assuming response variable is "loan.fund.sources", build a classification model.

# 1. The response variable has several levels and is imbalanced
ggplot(data = df.2, aes(x=loan.fund.sources))+
  geom_bar()+
  theme_bw()
# 2. split data into train, test split
# split the train dataset into train and test set
set.seed(2021)
index <- createDataPartition(df.2$loan.fund.sources, p = 0.7, list = FALSE)
df_train <- df.2[index, ]
df_test  <- df.2[-index, ]
# 3. Build model on imbalanced multi-level data

# 4. Imbalanced data model evaluation
# 5. Balance data & model evaluation

# Alternatove