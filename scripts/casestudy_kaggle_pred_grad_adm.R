
# data source: Kaggle- Graduate Admission
# data source url: https://www.kaggle.com/mohansacharya/graduate-admissions
# Objective: Prediction of graduate admissions in a masters course
# Evaluation metric: RMSE
# Data dictionary
### sop : statement of purpose; lor = letter of recommendation strength (out of 5)
### continuous vars: gre.score, tofel.score, sop, lor, cgpa, chance of admit
### discrete vars: university rating, research
### university rating (out of 5): 1=low rating, 5= highest rating


# required libraries
library(tidyverse)

# read data in memory
dat<- read.csv("kaggle_graduate_admissions/data/Admission_Predict.csv",
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
df<- dat %>%
  rename(gre_score = gre.score, toefl_score = toefl.score,
         univ_rating = university.rating, admit = chance.of.admit
         )
## 2. change data type 
# discrete vars: university rating, research. Change datatype to factor
df$univ_rating<- as.factor(df$univ_rating)
df$research<- as.factor(df$research)
table(df$sop)

# Exploratory visualization for detecting relationships
ggplot(data = df, aes(x=univ_rating, y=admit))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=lor))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=sop))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=cgpa))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=gre_score))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=toefl_score))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

p<-ggplot(data = df, aes(x = univ_rating, ..count..))
p + geom_bar(aes(fill=admit), position = "dodge")+
  #theme(axis.text.x = element_text(angle = 90))+
  theme_light()+
  ggtitle("(A) University rating vs Admission ")+
  scale_x_discrete(name="University rating")+
  scale_y_continuous(name = "count of admissions")
