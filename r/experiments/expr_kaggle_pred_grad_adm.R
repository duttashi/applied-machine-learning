
# data source: Kaggle- Graduate Admission
# data source url: https://www.kaggle.com/mohansacharya/graduate-admissions
# Objective: Prediction of graduate admissions in a masters course
# Evaluation metric: RMSE
# Data dictionary
### sop : statement of purpose; lor = letter of recommendation strength (out of 5)
### continuous vars: gre.score, tofel.score, sop, lor, cgpa, chance of admit
### discrete vars: university rating, research
### university rating (out of 5): 1=low rating, 5= highest rating

# Reference: http://r-statistics.co/Linear-Regression.html

# required libraries
library(tidyverse)
library(caret)
library(corrplot)


# read data in memory
dat<- read.csv("data/Admission_Predict.csv",
               header=T, na.strings=c("","NA"), stringsAsFactors = FALSE)

# Exploratory Data Analysis (EDA)

# check for missing values
sum(is.na(dat)) # 0 missing values

# lowercase the column names
for( i in 1:ncol(dat)){
  colnames(dat)[i] <- tolower (colnames(dat)[i])
}
## Data management decisions
## 1. change variable names
colnames(dat)
dat<- dat %>%
  rename(gre_score = gre.score, 
         toefl_score = toefl.score,
         univ_rating = university.rating, 
         admit = chance.of.admit
         )
## 2. change data type 
# discrete vars: university rating, research. Change datatype to factor
dat$univ_rating<- as.factor(dat$univ_rating)
dat$research<- as.factor(dat$research)
table(dat$sop)

# make a copy
df<- dat
# Exploratory visualization for detecting relationships
ggplot(data = df, aes(x=univ_rating, y=admit))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs Admission rate")+
  xlab("university rating")+
  ylab ("admission rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=lor))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs recommendation letter (lor)")+
  xlab("university rating")+
  ylab ("lor rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=sop))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs statement of purpose (sop)")+
  xlab("university rating")+
  ylab ("sop rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=cgpa))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs CGPA rate")+
  xlab("university rating")+
  ylab ("CGPA rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=gre_score))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs GRE rate")+
  xlab("university rating")+
  ylab ("GRE rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=toefl_score))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

p<-ggplot(data = df, aes(x = univ_rating, ..count..))
p + geom_bar(aes(fill=admit), position = "dodge")+
  theme_light()+
  ggtitle("(A) University rating vs Admission ")+
  scale_x_discrete(name="university rating")+
  scale_y_continuous(name = "admission count")

###### dimensionality reduction
# check for near zero variance cols and remove them
badCols<- nearZeroVar(df) # none
# check for collinearity
str(df)
corr1<- cor(df[,c(2:3,5:7,9)])
corrplot(corr1, method = "circle")
# remove variables with more than 75% correlation
hc <- findCorrelation(corr1, cutoff = 0.75)
hc<- sort(hc)
names(df[,hc]) # gre_score, sop and lor are highly correlated
df_reduced<- df[, -hc]
names(df_reduced)

##### PREDICTIVE MODELLING

# simple multiple linear regression model to predict the rate of student admission
admit_lm<- lm(admit~., data = train_data)
admit_rr<- train(admit~., data = train_data, method="ridge") # ridge regression
admit_lasso<- train(admit~., data = train_data, method="lasso") # lasso regression

predictions<- predict(admit_lm, data=test_data)
# Model performance
# (a) Compute the prediction error (RMSE)
summary(admit_lm) # variables lor, gre_score, tofel_score and cgpa are significant
# lets build another regression model only on variables lor, gre_score, tofel_score and cgpa
admit_lm_1<- lm(admit~lor+cgpa+gre_score+toefl_score, data = train_data)
summary(admit_lm_1)
# prediction on the revised model
predictions<- predict(admit_lm_1, data=test_data)

# (b) Calculate the prediction accuracy and error rates
actuals_preds <- data.frame(cbind(actuals=test_data$admit, predicteds=predictions))  # make actuals_predicteds dataframe.
correlation_accuracy <- cor(actuals_preds)  
correlation_accuracy # -0.057%
head(actuals_preds)
min_max_accuracy <- mean(apply(actuals_preds, 1, min) / apply(actuals_preds, 1, max))  
# 80%, min-max accuracy
mape <- mean(abs((actuals_preds$predicteds - actuals_preds$actuals))/actuals_preds$actuals) 
# 23% mean absolute precentage deviation
predictions<- predict(admit_lm_1, data=test_data)


# define training control
train_control <- trainControl(method="repeatedcv", number=10, repeats=3)


# split data into train and test by cross validation
set.seed(2020)
index <- createDataPartition(df$admit, p = 0.7, list = FALSE)
train_data <- df[index, ]
test_data  <- df[-index, ]
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary
)
