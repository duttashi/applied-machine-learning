# Data source: https://www.kaggle.com/iabhishekofficial/mobile-price-classification
# Problem statement: 
# 1. To find out some relation between features of a mobile phone(eg:- RAM,Internal Memory etc) and its selling price
# 2. Predict the price range
# Problem type: multi-level classification
# Evaluation metric: 

# load required libraries
library(readr) # for read_csv()
library(magrittr) # for %>% operator
library(FactoMineR) # pca()
library(caret) # for nearZeroVar()
library(corrplot)
library(factoextra) # fviz_screeplot()
library(gridExtra)
library(grid)

# clean the workspace
rm(list = ls())

# read the data
df_train<- read_csv("data/kaggle_mobile_phone_classify_data_train.csv")
df_test<- read_csv("data/kaggle_mobile_phone_classify_data_test.csv")

# combine train & test set
# colnames(df_train)
# colnames(df_test)
# df_test$id<- NULL
# df<- merge(df_train, df_test, all = TRUE)
# head(df)
table(df_train$price_range)
colnames(df_train)

# Preliminary predictive modelling
badCols <- nearZeroVar(df_train) # no bad cols

# check for correlation
cor1<- cor(df_train)
corrplot(cor1, number.cex = .7) 
# high positive correlations: pc & fc, four_g & three_g
# high negative correlations: ram & price_range, sc_h & sc_w

# correlation treatment
df_train.pca<- PCA(df_train, graph = FALSE)
#Scree plot to visualize the PCA's
screeplot<-fviz_screeplot(df_train.pca, addlabels = TRUE,
                          barfill = "gray", barcolor = "black",
                          ylim = c(0, 50), xlab = "Principal Component (PC) for continuous variables", ylab = "Percentage of explained variance",
                          #main = "(A) Scree plot: Factors affecting air crash survival ",
                          ggtheme = theme_minimal())
# Determine Variable contributions to the principal axes
# Contributions of variables to PC1
pc1<-fviz_contrib(df_train.pca, choice = "var", 
                  axes = 1, top = 10, sort.val = c("desc"),
                  ggtheme= theme_minimal())+
  labs(title="(B) PC-1")

# Contributions of variables to PC2
pc2<-fviz_contrib(df_train.pca, choice = "var", axes = 2, top = 10,
                  sort.val = c("desc"),
                  ggtheme = theme_minimal())+
  labs(title="(C) PC-2")

fig1<- grid.arrange(arrangeGrob(screeplot), 
                    arrangeGrob(pc1,pc2, ncol=1), ncol=2, widths=c(2,1)) 
# clear the graphic device
grid.newpage()

# variables to keep are
vars_to_keep<- c("ram","px_width","fc","pc","sc_w","sc_h","four_g","three_g","price_range")
df_train_impvars<- df_train[,vars_to_keep]

# Run algorithms using 10-fold cross validation
set.seed(2020)
index <- createDataPartition(df_train_impvars$price_range, p = 0.7, list = FALSE)
train_data <- df_train_impvars[index, ]
test_data  <- df_train_impvars[-index, ]
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE)

# Build models

# Linear regression
linear_model = lm(formula = price_range ~ .,
                  data = train_data) 
result = predict(linear_model, test_data) 
head(result)
result_model_lm <-  data.frame(actual_price_range = test_data$price_range,
                            predict_price_range = result)

write.csv(result_model_lm, "data/kaggle_mobile_phone_classify_model_lm_preds.csv", row.names = F)

# CART
set.seed(2020)

fit_cart<-caret::train(item_cnt_day ~ .,data = sales_dat,
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "RMSE"
)
# kNN
set.seed(2020)

fit_knn<-caret::train(item_cnt_day ~ .,data = train_data,
                      method = "knn",
                      preProcess = c("scale", "center"),
                      trControl = ctrl 
                      , metric= "RMSE"
)