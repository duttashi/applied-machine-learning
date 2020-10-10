# Data Source: https://www.kaggle.com/c/avazu-ctr-prediction/data
# Question: Predict whether a mobile ad will be clicked
# target variable: click: 0/1 for non-click/click

library(data.table)
# dat<- fread(input = "data/avazu-ctr-prediction/test.csv")
# df<- dat[sample(nrow(dat),25000),]
# write.csv(df, file = "data/avazu-ctr-prediction/test_tiny.csv")

# read the data
df_train <- fread(input = "data/avazu-ctr-prediction/train_tiny.csv")
df_test <- fread(input = "data/avazu-ctr-prediction/test_tiny.csv")

table(df_train$click) # imbalanced target variabe

