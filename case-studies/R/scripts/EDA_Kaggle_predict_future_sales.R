
# sales prediction
# reference: https://www.kaggle.com/c/competitive-data-science-predict-future-sales/data

# read data
sales_dat<- read.csv("kaggle_sales_prediction/data/sales_train.csv", header = TRUE, sep = ",")
items_dat<-read.csv("kaggle_sales_prediction/data/items.csv", header = TRUE, sep = ",")
test_dat<- read.csv("kaggle_sales_prediction/data/test.csv", header = TRUE, sep = ",")
# EDA
names(sales_dat)
names(items_dat)
names(test_dat)
# merge the sale and shops data
sales_data<- merge.data.frame(sales_dat, items_dat, by="item_id")
# replace item name as null
sales_data$item_name<- NULL
head(sales_data)
str(sales_data)
rm(sales_dat)
# coerce date to date format
library(lubridate) # for dmy()
sales_data$date<- dmy(sales_data$date)

# Feature engineering
# split the date into separate columns
library(magrittr) # %>%
library(tidyr) # separate()
sales_data<- sales_data %>%
  separate(date, into = c("sales_year","sales_month","sales_day"))
sales_data$sales_year<- as.integer(sales_data$sales_year)
sales_data$sales_month<- as.integer(sales_data$sales_month)
sales_data$sales_day<- as.integer(sales_data$sales_day)
head(sales_data)  
sum(is.na(sales_data))

# Preliminary predictive modelling
library(caret)
badCols <- nearZeroVar(sales_data) # no bad cols

# check for correlation
str(sales_data)
cor1<- cor(sales_data)
library(corrplot)
corrplot(cor1, number.cex = .7) # date_block_num and sales_year are high positive correlated

# correlation treatment
library(FactoMineR) # pca()
sales_data.pca<- PCA(sales_data, graph = FALSE)
#Scree plot to visualize the PCA's
screeplot<-fviz_screeplot(sales_data.pca, addlabels = TRUE,
                          barfill = "gray", barcolor = "black",
                          ylim = c(0, 50), xlab = "Principal Component (PC) for continuous variables", ylab = "Percentage of explained variance",
                          #main = "(A) Scree plot: Factors affecting air crash survival ",
                          ggtheme = theme_minimal()
                          )
# Determine Variable contributions to the principal axes
# Contributions of variables to PC1
pc1<-fviz_contrib(sales_data.pca, choice = "var", 
                  axes = 1, top = 10, sort.val = c("desc"),
                  ggtheme= theme_minimal())+
  labs(title="(B) PC-1")

# Contributions of variables to PC2
pc2<-fviz_contrib(sales_data.pca, choice = "var", axes = 2, top = 10,
                  sort.val = c("desc"),
                  ggtheme = theme_minimal())+
  labs(title="(C) PC-2")

library(gridExtra)
library(grid)
fig1<- grid.arrange(arrangeGrob(screeplot), 
                    arrangeGrob(pc1,pc2, ncol=1), ncol=2, widths=c(2,1)) 
# clear the graphic device
grid.newpage()

# variables to keep are
vars_to_keep<- c("date_block_num","sales_year",'item_category_id',"item_id","item_price", "item_cnt_day", "shop_id")
sales_data_impvars<- sales_data[,vars_to_keep]

# Run algorithms using 10-fold cross validation
set.seed(2020)
index <- createDataPartition(sales_data_impvars$item_cnt_day, p = 0.7, list = FALSE)
train_data <- sales_data_impvars[index, ]
test_data  <- sales_data_impvars[-index, ]
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     )

# Build models

# Linear regression
linear_model = lm(formula = item_cnt_day ~ shop_id + item_id,
                  data = sales_dat) 

result = predict(linear_model, test_dat[,c("shop_id","item_id")]) 
head(result)
submission =  data.frame(ID = test_dat$ID,
                         item_cnt_month = result)

table(unique(sales_dat$item_cnt_day))

write.csv(submission, "kaggle_sales_prediction/data/submission_future_sales.csv", row.names = F)

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