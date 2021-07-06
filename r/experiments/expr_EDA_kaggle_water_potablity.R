# Data Source: https://www.kaggle.com/adityakadiwal/water-potability
# Objective: To clasify if water quality is drinkable or not
# Submission: 


library(tidyverse)
library(caret)

df<- read.csv("data/kaggle_water_potability.csv", 
              na.strings = c("",NA))

colSums(is.na(df))
table(df$Potability)
# Indicates if water is safe for human consumption 
# where 1 means Potable and 0 means Not potable.

# Missing value treatement
# impute missing values with median or mode

df_clean<- data.frame(lapply(df,function(x) 
  {
  if(is.numeric(x)) 
    ifelse(is.na(x),median(x,na.rm=T),x) 
  else x
  }))
sum(is.na(df_clean))

# convert the response variable to factor data type
df_clean$Potability<- factor(df_clean$Potability)
# renname the levels
df_clean$Potability <- recode_factor(df_clean$Potability, 
                                     "1"="potable", "0"="not_potable")
levels(df_clean$Potability)

# Modeling the original imbalanced data
# split the train data
set.seed(2021)
index <- createDataPartition(df_clean$Potability, p = 0.7, list = FALSE)
train_data <- df_clean[index, ]
test_data  <- df_clean[-index, ]

# set the control function
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary)

set.seed(2021)
fit_cart<-caret::train(Potability ~ .,data = train_data[,c(-1)],
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC")

# make prediction on imbalanced data
predictions <- predict(fit_cart, test_data[,c(-1)])
confusionMatrix(predictions, test_data$Potability) # 74% on imbalanced data
final <- data.frame(actual = test_data$Potability,
                    predict(fit_cart, newdata = test_data[,c(-1)], type = "prob"))
final$predict <- ifelse(final$potable > 0.5, "Yes", "No")
final$predict<- factor(final$predict)

# PREDICTIVE MODELLING On BALANCED DATA
# Method 2: Over-Sampling
set.seed(2021)
ctrl <- trainControl(method = "repeatedcv", 
                     number = 10, 
                     repeats = 10, 
                     verboseIter = FALSE,
                     sampling = "up",
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary)

fit_cart_over<-caret::train(Potability ~ .,data = train_data[,c(-1)],
                            method = "rpart",
                            preProcess = c("scale", "center"),
                            trControl = ctrl 
                            ,metric= "ROC")


# Make Predictions using the best model
predictions <- predict(fit_cart_over, test_data)
# create a submission file
submt<- data.frame(test_data$Potability, predictions)

write.table(submt,"data/kaggle_potable_water_rpart_model.csv", 
            col.names = c("Potability","predict_val"),
            sep = ",", row.names = FALSE)
