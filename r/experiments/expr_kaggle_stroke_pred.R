# Data source: Kaggle Home Loan Default prediction
# Source url: https://www.kaggle.com/fedesoriano/stroke-prediction-dataset
# Competition type: imbalanced binary classification
# target/response variable to predict: stroke
# evaluation metric: F1-Score (given the output class imbalance)
# challenge aim: 

# clean the worspace
rm(list = ls())

# load required libraries
library(plyr) # for revalue()
library(dplyr) # for mutate()
library(magrittr) # for the pipe operator
library(ggplot2) # for ggplot
library(caret) # for predictive modelling
library(mice) # for missing data imputation

# read the data
df<- read.csv("data/kaggle_healthcare-dataset-stroke-data.csv",
              sep = ",")
table(df$stroke) # imbalanced binary classification

# Data Management Decisions

# 1. lower case all variables
# lowercase column names
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}
# lower case all variable names
df<- lowercase_cols(df)

# 2. change variable data type
df<- df %>%
  mutate(stroke = as.factor(stroke)) %>%
  mutate(heart_disease = as.factor(heart_disease)) %>%
  mutate(hypertension = as.factor(hypertension)) %>%
  mutate(smoking_status = as.factor(smoking_status))

# 3. rename variable values
df$smoking_status<- revalue(df$smoking_status, 
                            c("Unknown"=NA, "formerly smoked"="formerly_smoked",
                              "never smoked"="never_smoked","smokes"="currently_smokes"))
df$heart_disease<- revalue(df$heart_disease, c("0"="heartdisease_no","1"="heartdisease_yes"))
df$hypertension<- revalue(df$hypertension, c("0"="hypertension_no","1"="hypertension_yes"))
df$stroke<- revalue(df$stroke, c("0"="stroke_no","1"="stroke_yes"))

#4. data visualization
g1 <- ggplot(df,aes(gender,fill = stroke))+
  geom_bar()+
  labs(title = "Heart attack by gender\n",
       y = "Count",
       x = "Sex")+
  theme(legend.position = "top")+
  scale_fill_discrete(name = "Heart Attack", labels = c("No","Yes"))+
  theme_light()
g1 # females are slightly more prone to stroke

#5. missing values
sum(is.na(df))
colSums(is.na(df)) # smoking status

#5.1 Missing value imputation
imputed = mice(df, print=FALSE, seed = 2021, threshold=1)
df_cmplt = complete(imputed,2) 
sum(is.na(df_cmplt))
View(df_cmplt)
table(df_cmplt$smoking_status)
colSums(is.na(df_cmplt))

# Predictive modelling

# Create random training, validation, and test sets
set.seed(2021)
# Set the fractions of the dataframe you want to split into training, 
# validation, and test.
fractionTraining   <- 0.60
fractionValidation <- 0.20
fractionTest       <- 0.20

# Compute sample sizes.
sampleSizeTraining   <- floor(fractionTraining   * nrow(df_cmplt))
sampleSizeValidation <- floor(fractionValidation * nrow(df_cmplt))
sampleSizeTest       <- floor(fractionTest       * nrow(df_cmplt))

# Create the randomly-sampled indices for the dataframe. Use setdiff() to
# avoid overlapping subsets of indices.
indicesTraining    <- sort(sample(seq_len(nrow(df_cmplt)), size=sampleSizeTraining))
indicesNotTraining <- setdiff(seq_len(nrow(df_cmplt)), indicesTraining)
indicesValidation  <- sort(sample(indicesNotTraining, size=sampleSizeValidation))
indicesTest        <- setdiff(indicesNotTraining, indicesValidation)

# Finally, output the three dataframes for training, validation and test.
dfTraining   <- df_cmplt[indicesTraining, ]
dfValidation <- df_cmplt[indicesValidation, ]
dfTest       <- df_cmplt[indicesTest, ]

# Model building on imbalanced data
# Data resampling:  10-fold cross validation
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary)

# Build Initial models
# recursive Partitioning/Decision Trees 
set.seed(2021)
fit_rpart<-caret::train(stroke ~ .,data = dfTraining,
                        method = "rpart",
                        preProcess = c("scale", "center"),
                        trControl = ctrl 
                        ,metric= "prSummary")
# Generalised Linear Modellig
set.seed(2021)
fit_glm<-caret::train(stroke ~ .,data = dfTraining
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "prSummary")

# summarize accuracy of models
models <- resamples(list(rpart=fit_rpart, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_rpart, dfTest)
confusionMatrix(predictions, dfTest$stroke) # 85% accuracy on imbalaned data. Positive class is not interested

# PREDICTIVE MODELLING On BALANCED DATA
# Method 1: Under Sampling
set.seed(2021)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , sampling = "down"
                     , summaryFunction=twoClassSummary
                     )

fit_rpart_under<-caret::train(stroke ~ .,data = dfTraining,
                              method = "rpart",
                              preProcess = c("scale", "center"),
                              trControl = ctrl 
                              , metric= "prSummary")

# Method 2: Over Sampling
set.seed(2021)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , sampling = "up"
                     , summaryFunction=twoClassSummary
)

fit_rpart_over<-caret::train(stroke ~ .,data = dfTraining,
                             method = "rpart",
                             preProcess = c("scale", "center"),
                             trControl = ctrl
                             , metric= "prSummary"
)
# Method 3: Hybrid Sampling (ROSE)
set.seed(2021)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , sampling = "rose"
                     , summaryFunction=twoClassSummary
)

fit_rpart_rose<-caret::train(stroke ~ .,data = dfTraining,
                             method = "rpart",
                             preProcess = c("scale", "center"),
                             trControl = ctrl 
                             , metric= "prSummary"
)

# rf
fit_over_gbm<-caret::train(stroke ~ .,data = dfTraining,
                           method = "gbm",
                           preProcess = c("scale", "center"),
                           trControl = ctrl
                           , metric= "prSummary")
# summarize accuracy of models
models <- resamples(list(rpart_under=fit_rpart_under, rpart_over=fit_rpart_over, rpart_rose=fit_rpart_rose))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_rpart_over, dfTest)
# Using over-balancing as a method for balancing the data, the rpart model AUC on balanced data reduced to 0.73
confusionMatrix(predictions, dfTest$stroke) # 83% AUC on balanced rpart under sampling model

# FINAL MODEL BUILDING ON TEST DATA
#Test set predictions:
df$Preds <- predict(fit_rpart_over, newdata = dfValidation)
str(df$Preds)
df$Preds<- revalue(df$Preds,c("stroke_yes"="1",
                              "stroke_no"="0")
)
# create submission file
submission <- data_test %>%
  select(id, Preds)
colnames(submission) <- c("id", "Response")
# write to disc
write.csv(submission, file = "data/soln_kaggle_stroke_pred.csv", row.names = FALSE)
# 78% AUC score on public leaderboard with Rpart and over sample data

#################
