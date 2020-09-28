# Kaggle heart failure prediction dataset analysis
# datasource: https://www.kaggle.com/andrewmvd/heart-failure-clinical-data
# Data dictionary
# Sex - Gender of patient Male = 1, Female =0
# Age - Age of patient
# Diabetes - 0 = No, 1 = Yes
# Anaemia - 0 = No, 1 = Yes
# High_blood_pressure - 0 = No, 1 = Yes
# Smoking - 0 = No, 1 = Yes
# DEATH_EVENT - 0 = No, 1 = Yes

library(tidymodels)

# clean the worspace
rm(list = ls())
# load required data
df<- read.csv(file = "data/kaggle_heart_failure_clinical_records_dataset.csv",
              header = TRUE, sep = ",")
# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}

df<- lowercase_cols(df)
head(df)

df$death_event<- as.factor(df$death_event)
df$anaemia <- as.factor(df$anaemia)
df$diabetes <- as.factor(df$diabetes)
df$high_blood_pressure <- as.factor(df$high_blood_pressure)
df$sex <- as.factor(df$sex)
df$smoking <- as.factor(df$smoking)
# rename the factor levels for response variable
df<- df %>%
  mutate(death_event = recode(death_event, "0" = "No", "1" ="Yes"))


# data visualization
g1 <- ggplot(df,aes(sex,fill = death_event))+
  geom_bar()+
  labs(title = "Sex and Heart Attack Result Counts\n",
       y = "Count",
       x = "Sex")+
  theme(legend.position = "top")+
  scale_fill_discrete(name = "Heart Attack Resulted in Death", labels = c("No","Yes"))+
  scale_x_discrete(labels = c("Female","Male"))
g1

# Predictive modelling
library(caret)
# split the train dataset into train and test set
set.seed(2020)
colnames(df)
index <- createDataPartition(df$death_event, p = 0.7, list = FALSE)
df_train <- df[index, ]
df_test  <- df[-index, ]
table(df$death_event) # imbalanced data

# Model building on imbalanced data
# Data resampling:  10-fold cross validation
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary)
# Build Initial models
# recursive Partitioning/Decision Trees 
set.seed(2020)
str(df_train)
fit_rpart<-caret::train(death_event ~ .,data = df_train,
                        method = "rpart",
                        preProcess = c("scale", "center"),
                        trControl = ctrl 
                        ,metric= "ROC")
# Generalised Linear Modellig
set.seed(2020)
fit_glm<-caret::train(death_event ~ .,data = df_train
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC")

# summarize accuracy of models
models <- resamples(list(rpart=fit_rpart, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_rpart, df_test)
confusionMatrix(predictions, df_test$death_event) # 85% accuracy on imbalaned data. Positive class is not interested

# PREDICTIVE MODELLING On BALANCED DATA
# Method 1: Under Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , sampling = "down"
                     , summaryFunction=twoClassSummary
)

fit_rpart_under<-caret::train(death_event ~ .,data = df_train,
                              method = "rpart",
                              preProcess = c("scale", "center"),
                              trControl = ctrl 
                              , metric= "ROC")

# Method 2: Over Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , sampling = "up"
                     , summaryFunction=twoClassSummary
)

fit_rpart_over<-caret::train(death_event ~ .,data = df_train,
                             method = "rpart",
                             preProcess = c("scale", "center"),
                             trControl = ctrl
                             , metric= "ROC"
)
# Method 3: Hybrid Sampling (ROSE)
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , sampling = "rose"
                     , summaryFunction=twoClassSummary
)

fit_rpart_rose<-caret::train(death_event ~ .,data = df_train,
                             method = "rpart",
                             preProcess = c("scale", "center"),
                             trControl = ctrl 
                             , metric= "ROC"
)

# rf
fit_over_gbm<-caret::train(death_event ~ .,data = df_train,
                           method = "gbm",
                           preProcess = c("scale", "center"),
                           trControl = ctrl
                           , metric= "ROC")
# summarize accuracy of models
models <- resamples(list(rpart_under=fit_rpart_under, rpart_over=fit_rpart_over, rpart_rose=fit_rpart_rose))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_rpart_over, df_test)
# Using over-balancing as a method for balancing the data, the rpart model AUC on balanced data reduced to 0.73
confusionMatrix(predictions, df_test$death_event) # 83% AUC on balanced rpart under sampling model

# FINAL MODEL BUILDING ON TEST DATA
#Test set predictions:
df$Preds <- predict(fit_rpart_over, newdata = df_test)
str(df$Preds)
df$Preds<- revalue(df$Preds,c("interested"="1",
                                            "not_interested"="0")
)
# create submission file
submission <- data_test %>%
  select(id, Preds)
colnames(submission) <- c("id", "Response")
# write to disc
write.csv(submission, file = "data/soln_av_crossell_pred_ann_prem_bins.csv", row.names = FALSE)
# 78% AUC score on public leaderboard with Rpart and over sample data

#################
