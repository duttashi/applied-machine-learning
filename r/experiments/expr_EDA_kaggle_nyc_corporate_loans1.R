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

# 

# PM on Imbalanced data
library(xgboost)
names(df.2)

# Run algorithms using 3-fold cross validation
set.seed(2021)
df.2<- df.1
index <- createDataPartition(df.2$loan.fund.sources, p = 0.7, list = FALSE, times = 1)
train_data <- df.2[index, ]
test_data  <- df.2[-index, ]

# xgboost requires data in matrix format
data_label <- df.2[,"loan.fund.sources"]
data_matrix <- xgb.DMatrix(data = as.matrix(df.2), label = data_label)


numberOfClasses <- length(unique(df.2$loan.fund.sources))
xgb_params <- list("objective" = "multi:softprob",
                   "eval_metric" = "mlogloss",
                   "num_class" = numberOfClasses)
nround    <- 50 # number of XGBoost rounds
cv.nfold  <- 5
# Fit cv.nfold * cv.nround XGB models and save OOF predictions
cv_model <- xgb.cv(params = xgb_params,
                   data = train_data, 
                   nrounds = nround,
                   nfold = cv.nfold,
                   verbose = FALSE,
                   prediction = TRUE)




# create caret trainControl object to control the number of cross-validations performed
library(rpart.plot)
names(df.2)
rpart_model <- rpart(loan.fund.sources~recipient.city+interest.rate+loan.terms.completed+
                       loanaward_month+loan_purpose+original.loan.amount+loan.length+amount.repaid, 
                    train_data)



#　rpart.plot(rpart_model)
visTree(rpart_model)


ctrl <- trainControl(method = "repeatedcv",
                     number = 3,
                     # repeated 3 times
                     repeats = 3, 
                     verboseIter = FALSE, 
                     classProbs=FALSE, 
                     summaryFunction=multiClassSummary
                     )
set.seed(2021)
# turning "warnings" off
options(warn=-1)
metric <- "logLoss"
names(train_data)
# knn
m_knn <- train(loan.fund.sources ~., data = train_data[,c(2,4,6:18)], 
               method="kknn",metric=metric, 
               trControl=ctrl, preProcess = c("center", "scale"))


# Model summary
models <- resamples(list(logreg = fit_logreg, gbm = fit_gbm, lda = fit_lda))
summary(models)
# compare models
dotplot(models)
bwplot(models)
# Make Predictions using the best model
predictions <- predict(fit_logreg, test_data) # log reg has lowest specificity
confusionMatrix(predictions, test_data$class) # 98% accuracy, balanced accuracy # 75%
# Total cost imbalanced training data = 10*55+500*149 = $75,050


# PREDICTIVE MODELLING On BALANCED TRAINING DATA

# Method 1: Under Sampling
# turning "warnings" off
options(warn=-1)
ctrl <- trainControl(method = "repeatedcv",
                     number = 3, repeats = 3,
                     verboseIter = FALSE,
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "down")
# Logistic Regression on under sampled data
set.seed(2020)
fit_logreg_under<-train(class ~., data = train_data , 
                        method='glm', 
                        trControl=ctrl,  
                        metric = metric,
                        preProc = c("center", "scale")
)
# Logistic Regression on over sampled data
ctrl <- trainControl(method = "repeatedcv",
                     number = 3, repeats = 3,
                     verboseIter = FALSE,
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "up"
)
set.seed(2020)
fit_logreg_up<-train(class ~., data = train_data , 
                     method='glm', 
                     trControl=ctrl,  
                     metric = metric,
                     preProc = c("center", "scale")
)

# Logistic Regression on random over sampled data
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv",
                     number = 3, repeats = 3,
                     verboseIter = FALSE,
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "rose"
)
fit_logreg_rose<-train(class ~., data = train_data , 
                       method='glm', 
                       trControl=ctrl,  
                       metric = metric,
                       preProc = c("center", "scale")
)

# summarize models built on balanced data
models <- resamples(list(glm_under=fit_logreg_under, glm_over=fit_logreg_up, glm_rose=fit_logreg_rose))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_logreg_up, test_data)
# Using over-sampling as a method for balancing the data
confusionMatrix(predictions, test_data$class) # Total cost balanced training data (log reg over sampl)= 10*540+500*33 = $21,900




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