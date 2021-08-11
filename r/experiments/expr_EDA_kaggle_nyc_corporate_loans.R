# Data source: https://www.kaggle.com/theforcecoder/new-york-city-corporate-loans


library(tidyverse)
library(lubridate)
library(stringr) # for str_wrap()

# clean workspace
rm(list = ls())

# read data
df<- read_csv("data/kaggle_nyc_loans.csv",na=c("",NA))

# Data cleaning

# lowercase variable name & rename them
colnames(df)<- tolower(colnames(df))
# rename columns by replacing space with dot
df <- df %>%
  rename_all(list(~make.names(.)))
colnames(df)

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

# check missing data
sum(is.na(df))
colSums(is.na(df))

# filter columns with missing data
df<- df %>%
  filter(!is.na(df[,c(2:21)])) 
df<- df %>%
  filter(!is.na(df[, c(5:6)]))
df<- df %>%
  filter(!is.na(df[,c(13:14)]))
df<- df %>%
  filter(!is.na(df[,c(14)]))
colSums(is.na(df))
dim(df) # 5684 observations in 21 cols

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

# Let's look at the distributions.
# For example, with categorical data, the distribution simply describes the proportion of each unique category.
# Distribution visualisation for categorical data: use Barplot
str(df)
colnames(df)
ggplot(data = df, aes(x= loan_purpose))+
  geom_bar()+
  theme_bw()


# Individual feature visualisations
df %>%
  group_by(loanaward_year) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= loanaward_year, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="loanaward_year", y="Frequency")+
  coord_flip()+
  theme_bw()

summary(df$original.loan.amount)
df %>%
  filter(original.loan.amount<=200000) %>%
  ggplot(aes(x = loanaward_year, y = original.loan.amount)) +
  geom_point(color = "darkorchid4") +
  labs(title = "Corporate Loans - NYC",
       subtitle = "Loans per year",
       y = "Loan amount",
       x = "Year") + theme_bw(base_size = 12)

df %>%
  filter(original.loan.amount<=200000 & amount.repaid>0) %>%
  ggplot(aes(x = loanaward_year, y = amount.repaid)) +
  geom_point(color = "darkorchid4") +
  #facet_wrap(~loanaward_year)+
  labs(title = "Corporate Loans - NYC",
       subtitle = "Loans per year",
       y = "Amount repaid",
       x = "Year") + theme_bw(base_size = 12)

df %>%
  filter(original.loan.amount<=200000 & amount.repaid>0) %>%
  ggplot(aes(x = loanaward_year, y = amount.repaid)) +
  geom_bar(stat = "identity", fill = "darkorchid4") +
  facet_wrap( ~ loanaward_month, ncol = 3) +
  labs(title = "Corporate Loans - NYC",
       subtitle = "Loan amount repaid per year, month",
       y = "Amount repaid",
       x = "Year") + theme_bw(base_size = 12)
