# data source: https://www.kaggle.com/sakshigoyal7/credit-card-customers

# required libraries
library(caret)

# load data
df<- read.csv("data/kaggle_bankchurners.csv")
sum(is.na(df))
colnames(df)
# target variable is attrition flag; 0-acct close 1-acct open
table(df$Attrition_Flag) # imbalanced problem
# 2. Remove features with zero variance
badCols<- nearZeroVar(df)
colnames(df[,badCols])
df<- df[,-badCols]
str(df)
# 3. Rearrange character and numeric vars
# separate character and numeric cols apart
charcols <- colnames(df[,sapply(df, is.character)])
numcols <- colnames(df[, sapply(df, is.numeric)])
# rearrange cols such that numeric cols are first followed by character cols
df<- df[,c(charcols,numcols)] # character cols begins from index 36
str(df)

# 4. Find collinear features (works only for numeric features) as identified by a correlation coefficient greater than a specified value
str(df)
df_corr = cor(df[,c(7:20)])
hc = findCorrelation(df_corr, cutoff=0.75) # find vars that are 75% correlated 
hc = sort(hc)
colnames(df[,hc])
df = df[,-c(hc)]

# Model building on imbalanced dataset
# split the data into train and test
set.seed(2021)
df$Attrition_Flag<- factor(df$Attrition_Flag)
index <- createDataPartition(df$Attrition_Flag, p = 0.7, list = FALSE)
train_data <- df[index, ]
test_data  <- df[-index, ]
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary
)
# Build models
# CART
set.seed(2021)

fit_cart<-caret::train(Attrition_Flag ~ .,data = train_data,
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl
                       ,metric= "ROC"
)
# kNN
set.seed(2020)

fit_knn<-caret::train(TARGET ~ .,data = train_data,
                      method = "knn",
                      preProcess = c("scale", "center"),
                      trControl = ctrl
                      , metric= "ROC")

# # Logistic Regression
# set.seed(2020)
#
# fit_glm<-caret::train(TARGET ~ .,data = train_data
#                       , method = "glm", family = "binomial"
#                       , preProcess = c("scale", "center")
#                       , trControl = ctrl
#                       , metric= "ROC")

# Support Vector Machine
fit_svm<- caret::train(TARGET ~ .,data = train_data,
                       method = "svmLinear",
                       preProcess = c("scale", "center"),
                       trControl = ctrl)
# summarize accuracy of models
models <- resamples(list(cart=fit_cart, knn=fit_knn, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_glm, test_data)
confusionMatrix(predictions, test_data$TARGET) # 85% accuracy with kappa at 0.63


# Support Vector Machine
fit_svm<- caret::train(TARGET ~ .,data = train_data,
                       method = "svmLinear",
                       preProcess = c("scale", "center"),
                       trControl = ctrl)
# summarize accuracy of models
models <- resamples(list(cart=fit_cart, knn=fit_knn, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_glm, test_data)
confusionMatrix(predictions, test_data$TARGET) # 85% accuracy with kappa at 0.63
