# Data Source: https://www.kaggle.com/uciml/mushroom-classification

# Objective
# Identify features for correctly predicting mushroom as edible or posinous

# Data dictionary
# Attribute Information: (classes: edible=e, poisonous=p)
# 
# cap-shape: bell=b,conical=c,convex=x,flat=f, knobbed=k,sunken=s
# 
# cap-surface: fibrous=f,grooves=g,scaly=y,smooth=s
# 
# cap-color: brown=n,buff=b,cinnamon=c,gray=g,green=r,pink=p,purple=u,red=e,white=w,yellow=y
# 
# bruises: bruises=t,no=f
# 
# odor: almond=a,anise=l,creosote=c,fishy=y,foul=f,musty=m,none=n,pungent=p,spicy=s
# 
# gill-attachment: attached=a,descending=d,free=f,notched=n
# 
# gill-spacing: close=c,crowded=w,distant=d
# 
# gill-size: broad=b,narrow=n
# 
# gill-color: black=k,brown=n,buff=b,chocolate=h,gray=g, green=r,orange=o,pink=p,purple=u,red=e,white=w,yellow=y
# 
# stalk-shape: enlarging=e,tapering=t
# 
# stalk-root: bulbous=b,club=c,cup=u,equal=e,rhizomorphs=z,rooted=r,missing=?
#   
#   stalk-surface-above-ring: fibrous=f,scaly=y,silky=k,smooth=s
# 
# stalk-surface-below-ring: fibrous=f,scaly=y,silky=k,smooth=s
# 
# stalk-color-above-ring: brown=n,buff=b,cinnamon=c,gray=g,orange=o,pink=p,red=e,white=w,yellow=y
# 
# stalk-color-below-ring: brown=n,buff=b,cinnamon=c,gray=g,orange=o,pink=p,red=e,white=w,yellow=y
# 
# veil-type: partial=p,universal=u
# 
# veil-color: brown=n,orange=o,white=w,yellow=y
# 
# ring-number: none=n,one=o,two=t
# 
# ring-type: cobwebby=c,evanescent=e,flaring=f,large=l,none=n,pendant=p,sheathing=s,zone=z
# 
# spore-print-color: black=k,brown=n,buff=b,chocolate=h,green=r,orange=o,purple=u,white=w,yellow=y
# 
# population: abundant=a,clustered=c,numerous=n,scattered=s,several=v,solitary=y
# 
# habitat: grasses=g,leaves=l,meadows=m,paths=p,urban=u,waste=w,woods=d

# Output
# Results may be submitted in terms of feature relevance for predictability using error rates as our evaluation metrics. It is suggested that cross validation be applied to generate these results. Some baseline results are shown below for basic feature selection techniques using a simple kernel ridge classifier and 10 fold cross validation.

# Type of task: feature selection for dimensionality reduction followed by classification
# required libraries
library(tidyverse)

# Exploratory Data Analysis
df<- read.csv("data/kaggle_mushrooms.csv")
table(df$class) 
# edible: 4208, poisnous: 3916
# problem type: imbalanced data classification problem
# data sampling methods are; under-sampling, over-sampling and hybrid sampling
# Total features excluding the target: 22
str(df)
class(df$class) # dependent variable is tyep character

df %>%
  sapply(function(x) sum(is.na(x)))

table(df$veil.type)
# Exclude:- veil-type (as it has only one type i.e. ‘partial’.)
colnames(df)
df<- data.frame(df[,-17])



ggplot(data = df, aes(x=class, y=population))+
  geom_count()+
  theme_classic()

# Supervised Feature Selection
library(Boruta)
# Perform Boruta search
# Ensure, the dependent variable is of class factor.
# Boruta will not run for character class variable
df$class<- as.factor(df$class)
boruta_output <- Boruta(class ~ ., data=na.omit(df), doTrace=0)  
names(boruta_output)
# Get significant variables including tentatives
boruta_signif <- getSelectedAttributes(boruta_output, withTentative = TRUE)
print(boruta_signif)
# Do a tentative rough fix
roughFixMod <- TentativeRoughFix(boruta_output)
boruta_signif <- getSelectedAttributes(roughFixMod)
print(boruta_signif)

# Variable Importance Scores
imps <- attStats(roughFixMod)
imps2 = imps[imps$decision != 'Rejected', c('meanImp', 'decision')]
head(imps2[order(-imps2$meanImp), ])  # descending sort

# Plot variable importance
plot(boruta_output, cex.axis=.7, las=2, xlab="", main="Variable Importance")  
# The columns in green are ‘confirmed’ and the ones in red are not. There are couple of blue bars representing ShadowMax and ShadowMin. They are not actual features, but are used by the boruta algorithm to decide if a variable is important or not.
