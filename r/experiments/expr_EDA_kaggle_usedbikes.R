# data source: https://www.kaggle.com/saisaathvik/used-bikes-prices-in-india

# required libraries
library(tidyverse)
library(caret)
library(gridExtra)
library(ggpubr)
library(grid)
# load data

df<- read.csv("data/kaggle_used_bikes.csv")
view(df)

# DATA MANAGEMENT
# lowercase all vars
str(df)
df<-df %>%
  # lowercase all character variables
  rename_all(tolower)
colnames(df)

# Initial plots
p<- ggplot(data = df, aes( x=brand, y=price))

A<- p +
  geom_boxplot(outlier.color = "red")+
  theme_light()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("(a) Bike Brand vs Price")+
  scale_x_discrete(name="brand")+
  scale_y_continuous(name = "price")


p<- ggplot(data = df, aes( x=brand, y=age))
  
B<- p +
  geom_boxplot(outlier.color = "red")+
  theme_light()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("(b) Bike Brand vs Bike Age")+
  scale_x_discrete(name="brand")+
  scale_y_continuous(name = "age")

p<- ggplot(data = df, aes( x=brand, y=power))
C <- p +
  geom_boxplot(outlier.color = "red")+
  theme_light()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("(c) Bike Brand vs Bike Power")+
  scale_x_discrete(name="brand")+
  scale_y_continuous(name = "power")


fig<- grid.arrange(arrangeGrob(A), 
                   arrangeGrob(B,C, ncol=1), ncol=2, widths=c(2,1)) 
annotate_figure(fig
                ,top = text_grob("Used Bikes", color = "black", face = "bold", size = 14)
                ,bottom = text_grob("Data source: \n Kaggle\n", color = "brown",
                                    hjust = 1, x = 1, face = "italic", size = 10)
                )
# Add a black border around the 2x2 grid plot
grid.rect(width = 1.00, height = 0.99, 
          gp = gpar(lwd = 2, col = "black", fill=NA))


# Correlation Detection & Treatment
## Detecting skewed variables
library(moments) # for skewness
skewedVars <- NA
for(i in names(df)){
  if(is.numeric(df[,i])){
    if(i != "abc"){
      # Enters this block if variable is non-categorical
      skewVal <- skewness(df[,i])
      print(paste(i, skewVal, sep = ": "))
      if(abs(skewVal) > 0.5){
        skewedVars <- c(skewedVars, i)
      }
    }
  }
}

# Correlation detection
# https://topepo.github.io/caret/pre-processing.html#identifying-correlated-predictors

descrCor<- cor(df[,c(2,4,6:7)])
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .999)
highlyCorDescr <- findCorrelation(descrCor, cutoff = .75)
df_filterd <- df[,-highlyCorDescr]
names(df_filterd)
descrCor2 <- cor(df_filterd[,c(1,3,5:6)])
summary(descrCor2[upper.tri(descrCor2)])


# Data splitting
set.seed(2021)

df<- df_filterd
index <- createDataPartition(df$price, p = 0.7, list = FALSE)
train_data <- df[index, ]
test_data  <- df[-index, ]

# Multiple Linear regression
names(train_data)
linear_train<- lm(price ~ age+power+kms_driven,
                  data = df)

# within sample prediction
train_data$price_pred <- predict(linear_train, train_data)

# out of samplee prediction
test_data$price_pred<- predict(linear_train, test_data)

# Mean Absolute Error
MAE_train <- abs((train_data$price) - (train_data$price_pred)) %>% mean 
MAE_test <- abs((test_data$price) - (test_data$price_pred)) %>% mean 

#MAPE
precenterror_test <- mean(abs((test_data$price) - (test_data$price_pred))/(test_data$price))*100
precenterror_train <- mean(abs((train_data$price) - (train_data$price_pred))/(train_data$price))* 100


# Plot results: Predicted vs Actual Sales 
g1 <- train_data %>% ggplot(aes(x=(train_data$price), y= (train_data$price_pred))) + geom_point() + 
  ggtitle(paste('Train set MAE:', round(MAE_train, 2),'     ','Training set MAPE',round(precenterror_train,2),'%'))+geom_smooth(method = "lm", se = FALSE)
g2 <- test_data %>% ggplot(aes(x=(test_data$price), y= (test_data$price_pred))) + geom_point() + 
  ggtitle(paste('Test set MAE:', round(MAE_test, 2),'     ', 'Test set MAPE',round(precenterror_test,2),'%'))+
  geom_smooth(method = "lm", se = FALSE)
grid.arrange(g1, g2, nrow=1, top='Predictive performance of linear regression')



