# Objective: Cross-sell prediction competition
# Hosted at: Analytics Vidhya
# Problem type: Imbalanced binary classification
# Evaluation metric: ROC_AUC score
# The response variable is imbalanced
# URL: https://datahack.analyticsvidhya.com/contest/janatahack-cross-sell-prediction/?utm_source=auto-email#ProblemStatement

# clean the workspace
rm(list = ls())

# required libraries
library(readr)
library(dplyr)
library(plyr)
library(caret)
library(magrittr)
library(ggplot2)
library(corrplot)

# load required data
data_train<- read_csv("data/av_crossell_pred_train.csv",na=c("",NA))
data_test<- read_csv("data/av_crossell_pred_test.csv",na=c("",NA))

# EDA
sum(is.na(data_train)) # no missing vals

# Data Manipulation
# recode cateorical variables
data_train$Gender<- revalue(data_train$Gender,c("Male"="1",
                                                "Female"="2"))
data_train$Vehicle_Age<- revalue(data_train$Vehicle_Age,c("< 1 Year"="1",
                                                          "> 2 Years"="2",
                                                          "1-2 Year"="3"))
data_train$Vehicle_Damage<- revalue(data_train$Vehicle_Damage,c("Yes"="1",
                                                                "No"="2"))
data_train$Response<- factor(data_train$Response)
data_train$Response<- revalue(data_train$Response,c("1"="interested",
                                                    "0"="not_interested"))
# write_csv(data_train, "data/av_crossell_pred_train_coded.csv")

# change data type as per data dictionary
data_train$Driving_License<- as.character(data_train$Driving_License)
data_train$Region_Code<- as.character(data_train$Region_Code)
data_train$Previously_Insured<- as.character(data_train$Previously_Insured)
data_train$Vehicle_Damage<- as.character(data_train$Vehicle_Damage)
data_train$Policy_Sales_Channel<- as.character(data_train$Policy_Sales_Channel)

# rearrange the vars
data_train<- data_train[,c(1,3,9,11,2,4:8,10,12)]

# Apply the same steps on test set
# Data Manipulation
# recode cateorical variables
data_test$Gender<- revalue(data_test$Gender,c("Male"="1",
                                                "Female"="2"))
data_test$Vehicle_Age<- revalue(data_test$Vehicle_Age,c("< 1 Year"="1",
                                                          "> 2 Years"="2",
                                                          "1-2 Year"="3"))
data_test$Vehicle_Damage<- revalue(data_test$Vehicle_Damage,c("Yes"="1",
                                                                "No"="2"))
# change data type as per data dictionary
data_test$Driving_License<- as.character(data_test$Driving_License)
data_test$Region_Code<- as.character(data_test$Region_Code)
data_test$Previously_Insured<- as.character(data_test$Previously_Insured)
data_test$Vehicle_Damage<- as.character(data_test$Vehicle_Damage)
data_test$Policy_Sales_Channel<- as.character(data_test$Policy_Sales_Channel)
# rearrange the vars
data_test<- data_test[,c(1,3,9,11,2,4:8,10)]

## Check for multicollinearity
# str(data_train)
# cor1<- cor(data_train[,-c(1,5:12)])
# corrplot(cor1, number.cex = .7) # no high correlation between numeric vars

# random sampling data of data with some outlier values
data_train_smp<- data_train %>%
  dplyr::sample_frac(.1)
dim(data_train_smp) # [1] 38111   12 use .01 for 3811

# split the train dataset into train and test set
set.seed(2020)
index <- createDataPartition(data_train_smp$Response, p = 0.7, list = FALSE)
df_train <- data_train_smp[index, ]
df_test  <- data_train_smp[-index, ]

# Model building on imbalanced data
# Data resampling:  10-fold cross validation
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary)
# Build Initial models
# recursive Partitioning/Decision Trees 
str(data_train_smp)
set.seed(2020)
str(df_train)
fit_rpart<-caret::train(Response ~ .,data = df_train[,-c(1,10)],
                        method = "rpart",
                        preProcess = c("scale", "center"),
                        trControl = ctrl 
                        ,metric= "ROC")

# Generalised Linear Modellig
set.seed(2020)
fit_glm<-caret::train(Response ~ .,data = df_train[,-c(1,10)]
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
confusionMatrix(predictions, df_test$Response) # 87% accuracy on imbalaned data. Positive class is not interested

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

fit_rpart_under<-caret::train(Response ~ .,data = df_train[,-c(1,11)],
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

fit_rpart_over<-caret::train(Response ~ .,data = df_train[,-c(1,11)],
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

fit_rpart_rose<-caret::train(Response ~ .,data = df_train[,-c(1,11)],
                             method = "rpart",
                             preProcess = c("scale", "center"),
                             trControl = ctrl 
                             , metric= "ROC"
                             )

# rf
fit_over_gbm<-caret::train(Response ~ .,data = df_train[,-c(1,11)],
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
predictions <- predict(fit_over_rf, df_test)
# Using over-balancing as a method for balancing the data, the rpart model AUC on balanced data reduced to 0.73
confusionMatrix(predictions, df_test$Response) # 79% AUC on balanced rpart under sampling model

# FINAL MODEL BUILDING ON TEST DATA
#Test set predictions:
data_test$Preds <- predict(fit_rpart_over, newdata = data_test)
str(data_test$Preds)
data_test$Preds<- revalue(data_test$Preds,c("interested"="1",
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
# FEATURE ENGINEERING
# create a binned variable based on Annual Premium
data_train %>%
  # 31700
  dplyr::filter(Annual_Premium<=64450) %>%
  ggplot(aes(x=as.factor(Response), y=Annual_Premium))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("Imbalanced class distribution on Annual Premium")+
  labs(x="user response", y="annual premium")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

median(data_test$Annual_Premium)

data_test %>%
  # median = 31642
  dplyr::filter(Annual_Premium<=60000) %>%
  ggplot(aes(x=as.factor(Gender), y=Annual_Premium))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("Imbalanced class distribution on Annual Premium")+
  labs(x="gender", y="annual premium")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

data_train_smoutlr<- data_train %>%
  filter(Annual_Premium<=64450)

data_test_smoutlr<- data_train %>%
  filter(Annual_Premium<=60000)

# Visualize the imbalanced data
data_train_smoutlr %>%
  ggplot(aes(x=as.factor(Response)))+
  geom_bar()+
  ggtitle("Imbalanced class distribution")+
  labs(x="user response", y="count")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

range(data_train_smoutlr$Annual_Premium)
# summ <- data_train_smoutlr %>% 
#   group_by(Annual_Premium) %>% 
#   summarize(mean = mean(Annual_Premium), median = median(Annual_Premium), sd = sd(Annual_Premium))


data_train_smoutlr$AP_bin<- Hmisc::cut2(data_train_smoutlr$Annual_Premium, g=5)
table(data_train_smoutlr$AP_bin)
# recode the AP_bin for training data
data_train_smoutlr$ap_bins<- recode(data_train_smoutlr$AP_bin,
                                    "[ 2630,21198)"="range_1",
                                    "[21198,28856)"="range_2",
                                    "[28856,34039)"="range_3",
                                    "[34039,40877)"="range_4",
                                    "[40877,64450]"="range_5") 
data_test$AP_bin<- Hmisc::cut2(data_test$Annual_Premium, g=5)
table(data_test$AP_bin)
# recode the AP_bin for test data
data_test$ap_bins<- recode(data_test$AP_bin,
                           "[ 2630, 21535)"="range_1",
                           "[21535, 29008)"="range_2",
                           "[29008, 34385)"="range_3",
                           "[34385, 41723)"="range_4",
                           "[41723,472042]"="range_5") 
str(data_train_smoutlr)
data_train_smoutlr$Annual_Premium<-NULL
data_train_smoutlr$AP_bin<-NULL
str(data_test)
data_test$AP_bin<-NULL