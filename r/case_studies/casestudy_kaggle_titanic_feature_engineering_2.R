
# reference: https://www.kaggle.com/cdeotte/titanic-using-name-only-0-81818

data_train <- read.csv("data/kaggle_titanic_train.csv", stringsAsFactors = TRUE, sep = ",", na.strings = c(""))
data_test<- read.csv("data/kaggle_titanic_test.csv", stringsAsFactors = TRUE, sep = ",", na.strings = c(""))

# the gender model
data_test$Survived[data_test$Sex=='male']<-0
data_test$Survived[data_test$Sex=='female']<-1
# create submission file
submit <- data.frame(PassengerId = data_test$PassengerId, Survived = data_test$Survived)
write.csv(submit,"data/kaggle_titanic_genderModel.csv",row.names=F)
