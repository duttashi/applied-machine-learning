# Data source: https://www.kaggle.com/ashydv/advertising-dataset
# Task: analyse the relationship between 'TV advertising' and 'sales' using a simple linear regression model.


library(readr)
library(ggplot2)

df<- read_csv(file = "data/kaggle_advertising.csv")
head(df)
p<-ggplot(data = df, mapping = aes(x=TV, group="Sales", binwidth=50))
p<-ggplot(data = df, mapping = aes(x=TV, y= "Newspaper"))
p+geom_histogram()
