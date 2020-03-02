
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
dat<- read.csv("data/Admission_Predict.csv",
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
dat<- dat %>%
  rename(gre_score = gre.score, toefl_score = toefl.score,
         univ_rating = university.rating, admit = chance.of.admit
         )
## 2. change data type 
# discrete vars: university rating, research. Change datatype to factor
dat$univ_rating<- as.factor(dat$univ_rating)
dat$research<- as.factor(dat$research)
table(dat$sop)

# make a copy
df<- dat
# Exploratory visualization for detecting relationships
ggplot(data = df, aes(x=univ_rating, y=admit))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs Admission rate")+
  xlab("university rating")+
  ylab ("admission rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=lor))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs recommendation letter (lor)")+
  xlab("university rating")+
  ylab ("lor rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=sop))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs statement of purpose (sop)")+
  xlab("university rating")+
  ylab ("sop rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=cgpa))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs CGPA rate")+
  xlab("university rating")+
  ylab ("CGPA rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=gre_score))+
  geom_boxplot(outlier.colour = "red")+
  ggtitle("University rating vs GRE rate")+
  xlab("university rating")+
  ylab ("GRE rate")+
  theme_light()

ggplot(data = df, aes(x=univ_rating, y=toefl_score))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()

p<-ggplot(data = df, aes(x = univ_rating, ..count..))
p + geom_bar(aes(fill=admit), position = "dodge")+
  theme_light()+
  ggtitle("(A) University rating vs Admission ")+
  scale_x_discrete(name="university rating")+
  scale_y_continuous(name = "admission count")
