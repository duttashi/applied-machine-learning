# data source url: https://archive.ics.uci.edu/ml/datasets/Dresses_Attribute_Sales
# objective: Exploratory Data Analysis

# clean the workspace
rm(list = ls())

# load required libraries
library(tidyverse)
library(caret)
# Get the Data
dress_data <- data.frame(read_csv(file = "data/uciml_dress_attribute.csv",na=c("null",NA)))
str(dress_data)

# EDA
sum(is.na(dress_data)) # 821 
colSums(is.na(dress_data)) 

# Preliminary observations
# 821 missing values. # Max missing values in vars FabricType, Decoration, Pattern.Type, waiseline, material
# rename the column names to lower case. 
# rename var waiseline to waistline
# rename var Pattern.Type to patterntype

# rename col names and save to new data frame
df<-dress_data %>%
  rename(dressid=Dress_ID, style=Style, price=Price, rating=Rating, 
         size=Size,season=Season, neckline = NeckLine, sleevelength = SleeveLength,
         waistline = waiseline, material = Material, fabrictype=FabricType,
         decoration = Decoration, patterntype=Pattern.Type, recommendation=Recommendation)

# coerce all character vars to factor type
df<-df %>%
  #str()
  mutate_if(is.character, as.factor)
# check that all factor levels are complete ie have value associate to the level
colSums(is.na(df))
levels(df$patterntype) # missing level name coded as ""
levels(df$price) # missing level name coded as ""
levels(df$season) # missing level name coded as ""
levels(df$neckline) # missing level name coded as ""
levels(df$waistline) # missing level name coded as ""
levels(df$material) # missing level name coded as ""
levels(df$fabrictype) # missing level name coded as ""
levels(df$decoration) # missing level name coded as ""
levels(df$patterntype)# missing level name coded as ""

## recode the factor levels 
df$style <- fct_collapse(df$style,
                         'casual'=c("bohemian","Brief","Casual","cute","fashion",
                                    "Flare","Novelty","OL","party","sexy","Sexy")
                         )
df$price <- fct_collapse(df$price,
                         'high'=c("High","high","very-high"),
                         'low' = c("low","Low"),
                         'medium'=c('Medium','Average'),
                         "none"="")
df$size <- fct_collapse(df$size, 'S'=c('s','S','small'))
df$season <- fct_collapse(df$season, 
                                 'autumn'=c('Automn',"Autumn"), 'spring'='Spring', 'summer'='Summer',
                                 'winter'='Winter', "none"=""
                                 )
# reference: https://www.pinterest.com/pin/489766528200439406/
df$neckline<- fct_collapse(df$neckline,
                           'none'=c('','NULL'),'bowneck'=c('boat-neck','bowneck'),
                           'collar'=c('mandarin-collor','turndowncollor','mandarin-collor','sqare-collor','peterpan-collor'),
                           'sweetheart'=c('sweetheart','Sweetheart'),
                           'v-neck'=c('o-neck','v-neck','slash-neck')
                           )
df$sleevelength<- fct_collapse(df$sleevelength,
                               "halfsleeve"=c("cap-sleeves","capsleeves",
                                              "half","halfsleeve",
                                              "Petal","short",
                                              "sleeevless","sleeveless","sleevless","sleveless",
                                              "threequarter","threequater","thressqatar",
                                              "turndowncollor","urndowncollor",
                                              "butterfly"),
                               "none"="NULL", "fullsleeve"="full")
df$waistline<- fct_collapse(df$waistline,"none"="")
df$material<- fct_collapse(df$material, "none"="", "silk"=c("milksilk","silk","sill"),
                           "others"=c("other","modal","model"))
df$fabrictype<- fct_collapse(df$fabrictype, "none"="", "flannel"=c("flannael","flannel"),
                             "knitted"=c("knitted","knitting"), 
                             "other"=c("organza","other","terry","worsted","tulle","dobby"),
                             "wool"=c("wollen","woolen"), "satin"=c("satin","sattin")
                             )
df$decoration<- fct_collapse(df$decoration, "none"="")
df$patterntype<- fct_collapse(df$patterntype, "none"=c("","none"), "animal"=c("animal","leapord","leopard"),
                              "patchwork"=c("patchwork","plaid","character","dot","splice","striped","character")
                              )
# recode the levels for recommendation
levels(df$recommendation)<- c("buy_dress","dont_buy")
##### Missing data visualization
library(VIM)
aggr(df, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
     labels=names(df), cex.axis=.7, gap=3, 
     ylab=c("Histogram of missing data","Pattern"))

##### Missing data imputation: impute the mising categorical data with mode for categorical data
# reference: https://stackoverflow.com/questions/7731192/replace-mean-or-mode-for-missing-values-in-r
Mode <- function (x, na.rm) {
  xtab <- table(x)
  xmode <- names(which(xtab == max(xtab)))
  if (length(xmode) > 1) xmode <- ">1 mode"
  return(xmode)
}

for (var in 1:ncol(df)) {
  if (class(df[,var])=="numeric") {
    df[is.na(df[,var]),var] <- median(df[,var], na.rm = TRUE)
  } else if (class(df[,var]) %in% c("character", "factor")) {
    df[is.na(df[,var]),var] <- Mode(df[,var], na.rm = TRUE)
  }
}

sum(is.na(df)) # 0

# write the clean data to disc
write.csv(df, file = "data/uciml_dress_clean.csv")

# Read the clean data from disc
df<- data.frame(read_csv(file = "data/uciml_dress_clean.csv"))
df$X1<- NULL
# coerce all character vars to factor type
df<-df %>%
  #str()
  mutate_if(is.character, as.factor)


# plots
str(df)
df %>%
  group_by(patterntype)%>%
  ggplot(aes(x=patterntype, y=rating))+
  geom_boxplot(outlier.color = "red", position = "dodge")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

df %>%
  ggplot(aes(x=style, y=rating))+
  geom_boxplot(outlier.color = "red", position = "dodge")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))




# Predictive modelling
# Run algorithms using 10-fold cross validation
set.seed(2020)
index <- createDataPartition(df$recommendation, p = 0.7, list = FALSE)
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
set.seed(2020)
fit_cart<-caret::train(factor(recommendation) ~ .,data = train_data,
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC")
# kNN
set.seed(2020)

fit_knn<-caret::train(recommendation ~ .,data = train_data,
                      method = "knn",
                      preProcess = c("scale", "center"),
                      trControl = ctrl 
                      , metric= "ROC")

# Logistic Regression
set.seed(2020)
fit_glm<-caret::train(recommendation ~ .,data = train_data
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC"
)
# summarize accuracy of models
models <- resamples(list(cart=fit_cart, knn=fit_knn, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_glm, test_data)
confusionMatrix(predictions, test_data$recommendation)
