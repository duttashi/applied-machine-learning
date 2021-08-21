# Data source: https://www.kaggle.com/theforcecoder/new-york-city-corporate-loans

# clean workspace
rm(list = ls())

library(tidyverse)
library(lubridate)
library(stringr) # for str_wrap()
library(caret)
# install.packages("ggcorrplot", dependencies = TRUE)
library(ggcorrplot)
library(moments) # for skewness() function


# read data
df<- read_csv("data/kaggle_nyc_loans.csv",na=c("",NA))
dim(df) # 13513 rows 18 cols

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

## Detecting skewed variables
str(df.1)
sapply(df.1[,c(19:21)], function(x) ifelse(skewness(x) > 0.75, x <- log1p(x), x))
# Highly skewed data for continuous variables
ggplot(data = df.1, aes(x=original.loan.amount))+
  geom_histogram() # right-skewed/positive skewed data
ggplot(data = df.1, aes(x=loan.length))+
  geom_histogram() # right-skewed/positive skewed data
ggplot(data = df.1, aes(x=amount.repaid))+
  geom_histogram() # right-skewed/positive skewed data

# Skewness treatment
# As all continuous variables are right/positively skewed, transformations can be square root, cube root and logarithms
# Applying logarithmic approach to reduce skewness
df.1$original.loan.amount<- log10(df.1$original.loan.amount)
df.1$loan.length<- log10(df.1$loan.length)
df.1$amount.repaid<- log10(df.1$amount.repaid)
range(df.1$original.loan.amount)
range(df.1$amount.repaid)
range(df.1$loan.length)

# filter rows where amount.repaid & loan.length is less than equal to zero
df.1<- df.1 %>%
  filter(amount.repaid>0 & loan.length>0)

ggplot(data = df.1, aes(x=original.loan.amount))+
  geom_histogram()+
  theme_bw()
ggplot(data = df.1, aes(x=loan.length))+
  geom_histogram()+
  theme_bw()
ggplot(data = df.1, aes(x=amount.repaid))+
  geom_histogram() +
  theme_bw()

# Let's look at the distributions.
# For example, with categorical data, the distribution simply describes the proportion of each unique category.
# Distribution visualisation for categorical data: use Barplot
str(df.1)
colnames(df)

ggplot(data = df.1, aes(x= loan_purpose))+
  geom_bar()+
  labs(x="loan purpose", y = "count", title = "Why people take loans?")+
  theme_bw()

# barplot with two categorical variables
ggplot(data = df.1, aes(loan_purpose, ..count..))+
  geom_bar(aes(fill=loan.fund.sources), position = "dodge")+
  labs(x="loan purpose", y = "count", title = "Which loan reason attracts funding agency?")+
  theme_bw()

ggplot(data = df.1, aes(recipient.state))+
  geom_bar()+
  labs(x="loan purpose", y = "count", 
       title = "Which states give maximum loans?")+
  theme_bw()

# filter data for NY state and remove the recipient.state variable
df.1 <- df.1 %>%
  filter(recipient.state=='NY')
df.1$recipient.state<- NULL

# Individual feature visualisations
df.1 %>%
  group_by(loanaward_year) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= loanaward_year, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="loanaward year", y="Frequency",
       title = "Which year bagged maximum loans?")+
  coord_flip()+
  theme_bw()

df.1 %>%
  filter(original.loan.amount<=200000) %>%
  ggplot(aes(x = loanaward_year, y = original.loan.amount)) +
  geom_point(color = "darkorchid4") +
  labs(title = "Corporate Loans - NYC",
       subtitle = "Loans per year",
       y = "Loan amount",
       x = "Year") + theme_bw(base_size = 12)


# filter out data where amount repaid for startup's is greater than 10000
df.1 <- df.1 %>%
  filter(amount.repaid>=1 & amount.repaid<=54000)%>%
  filter(original.loan.amount <= 200000) %>%
  filter(loanaward_year>=2000)

# boxplot
ggplot(data = df.1)+
  geom_boxplot(aes(x= loan_purpose, y=original.loan.amount),
               outlier.color="red")+
  labs(x="loan purpose", y = "original loan amount", title = "Loan reason's vs Loan amount")+
  theme_bw()

ggplot(data = df.1)+
  geom_boxplot(aes(x= loan_purpose, y=amount.repaid),
               outlier.color="red")+
  labs(x="loan purpose", y = "amount repaid", title = "Loan purpose vs Loan amount repaid")+
  theme_bw()

colnames(df.1)
df.1 %>%
  group_by(recipient.city)%>%
  summarise(OriginalLoanAmt=sum(original.loan.amount))%>%
  arrange(OriginalLoanAmt)
  #ggplot(aes(recipient.city))+
  #geom_bar()

# Change data type
# char_cols<- colnames(df.1[,c(1:10,17)])
# df.1[char_cols]<- sapply(df.1[char_cols], as.character)
# # rearrange the cols: character followed by numeric
# df.1<- df.1[,c(1:10,17,11:16)]
# str(df.1)

# CHECK FOR NEAR ZERO VARIANCE COLS
# Q. How many columns with near zero variance property?
badCols<- nearZeroVar(df.1)
dim(df.1[,badCols]) # [1] 5684 2
names(df.1[,badCols]) # [1] "new.jobs"      "fsYrEnd_month" "fsYrEnd_day"       "isFunded"     "isCollection" "paymt_min"    "paymt_sec"    "principal"
# remove the near zero variance predictors
df.1<- df.1[, -badCols]
dim(df.1) #[1] 3284 17

## Check for multicollinearity
# ggcorrplot(cor(df.1[,-c(1:10)]), type = "lower", lab = TRUE)

## Predictive Modeling
## Recode character variables to nominal
str(df.1)
df.1<- df.1 %>%
  mutate(across(authority.name:loan_purpose,~as.factor(.))) %>%
  mutate(across(authority.name:loan_purpose,~factor(.,levels = unique(.)))) %>%
  mutate(across(authority.name:loan_purpose,~as.numeric(.)))

## Assume ``amount.repaid` is the response variable `
# split the train dataset into train and test set
set.seed(2021)
index <- createDataPartition(df.1$amount.repaid, p = 0.7, list = FALSE)
df_train <- df.1[index, ]
df_test  <- df.1[-index, ]

# Model building 
# Build the model
str(df.1)
lm_model <- lm(amount.repaid ~ ., data = df_train)
# plot residual plots
# Residuals = Observed - Predicted
# mean of residuals sould be zero
mean(lm_model$residuals)
par(mfrow=c(2, 2))
plot(lm_model)
# The most useful way to plot the residuals, 
# is with your predicted values on the x-axis 
# and your residuals on the y-axis.

ggplot(lm_model, aes(x = .fitted, y = .resid)) +
  geom_point()+
  xlab("Predicted values for amount reapid")+
  ylab("Residuals")+
  ggtitle("Residual plot")+
  theme_bw()

# Make predictions and compute the R2, RMSE and MAE
predictions <- lm_model %>% predict(df_test)
data.frame( R2 = R2(predictions, df_test$amount.repaid),
            RMSE = RMSE(predictions, df_test$amount.repaid),
            MAE = MAE(predictions, df_test$amount.repaid))

residualVals <- df_test$amount.repaid - predictions
df.2 <- data.frame(df_test$amount.repaid, predictions, 
                   residualVals)
colnames(df.2)<- c("observed","predicted","residuals")


ggplot(data = df.2, aes(x=predicted, y=residuals))+
  geom_point()+
  xlab("Predicted values for amount reapid")+
  ylab("Residuals")+
  ggtitle("Residual plot")+
  theme_bw()


shapiro.test(residuals(lm_model))
range(df.1$amount.repaid)
summary(df.1$amount.repaid)

ggplot(data = df.1, aes(x= original.loan.amount, y=amount.repaid))+
  geom_point()
