# competition: predict number of upvotes
# hosted by: analytics vidya
# url: https://datahack.analyticsvidhya.com/contest/enigma-codefest-machine-learning-1/#ProblemStatement
# Problem type: regression
# evaluation metric: RMSE

# clean workspace
rm(list = ls())
# require libraries
library(readr)
library(rpart)
library(rpart.plot)

# read the data
train_data<- read_csv("data/av_train_NIR5Yl1.csv", na = c("","NA"))
test_data<- read_csv("data/av_test_8i3B3FC.csv", na = c("","NA"))
colnames(train_data)
table(train_data$Upvotes)

# initial model 
fit <- rpart(formula = Upvotes~., data = train_data, method = "anova", minbucket = 10, cp = -1)
rpart.plot(fit)
# Variable importance
fit$variable.importance

# Initial baseline prediction
predicted <- predict(fit, test_data)
summary(predicted)

# create initial baseline submission file
submission <- tibble('ID' = test_data$ID, 'Upvotes' = predicted)
write_csv(submission, 'data/av_predictupvote_baseline_subms.csv')
# Initial public leaderboard score with baseline model # 1854.556
