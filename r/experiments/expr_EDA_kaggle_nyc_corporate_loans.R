# Data source: https://www.kaggle.com/theforcecoder/new-york-city-corporate-loans


library(tidyverse)
library(lubridate)
library(stringr) # for str_wrap()
library(caret)
# clean workspace
rm(list = ls())

# read data
df<- read_csv("data/kaggle_nyc_loans.csv",na=c("",NA))
dim(df) # 13513 rows 18 cols

# Data cleaning

# lowercase variable name & rename them
colnames(df)<- tolower(colnames(df))
# rename columns by replacing space with dot
df <- df %>%
  rename_all(list(~make.names(.)))
colnames(df)

# split date into day, month, year cols
df<-df %>%
  mutate(
    fisclYrEndDate = mdy(fiscal.year.end.date),
    fsYrEnd_month = month(fisclYrEndDate),
    fsYrEnd_day = day(fisclYrEndDate),
    fsYrEnd_year = year(fisclYrEndDate)
    )

df<-df %>%
  mutate(loan_award_date = mdy(date.loan.awarded),
         loanaward_month = month(loan_award_date),
         loanaward_day = day(loan_award_date),
         loanaward_year = year(loan_award_date)
         )
# change month number to month name
df$loanaward_month<- month.name[df$loanaward_month]
df$fsYrEnd_month<- month.name[df$fsYrEnd_month]

# drop column
df$loan_award_date<- NULL
df$date.loan.awarded<- NULL
df$fiscal.year.end.date<- NULL
df$fisclYrEndDate<- NULL
df$fiscal.year.end.date<- NULL
# drop loans column because it has only 1 value "No" and rest values are blank
df$loans<-NULL

# check missing data
sum(is.na(df))
colSums(is.na(df))

# filter columns with missing data
df<- df %>%
  filter(!is.na(df[,c(2:21)])) 
df<- df %>%
  filter(!is.na(df[, c(5:6)]))
df<- df %>%
  filter(!is.na(df[,c(13:14)]))
df<- df %>%
  filter(!is.na(df[,c(14)]))
colSums(is.na(df))
dim(df) # 5684 observations in 21 cols

# Revalue Factor Levels for categorical variables
# It's observed in this dataset, few categorical variables such as `authority name, loan purpose` consist of very long factor names. These will pose a problem in data visualization.
loan_purpose_new_levels<- c("startup","build commercial property", 
                        "education","buy equipment",
                        "build residential property","buy land",
                        "restoration","recruitment")
df$loan.purpose<- as.factor(df$loan.purpose)
loan_purpose_existing_levels<- levels(df$loan.purpose)  
names(loan_purpose_existing_levels)<- loan_purpose_new_levels
# now using mutate and fct_recode to recode the factor levels
df <- df %>%
  mutate(loan_purpose = fct_recode(loan.purpose, !!!loan_purpose_existing_levels))
levels(df$loan_purpose)
# drop original variable
df$loan.purpose<- NULL
# lets wrap the text to no more than 10 spaces
df$loan_purpose<- str_wrap(df$loan_purpose, width = 4)

# change datatype
df$recipient.postal.code<- as.character(df$recipient.postal.code)
df$fsYrEnd_month<- as.character(df$fsYrEnd_month)
df$fsYrEnd_year<- as.character(df$fsYrEnd_year)
df$loanaward_month<- as.character(df$loanaward_month)
df$loanaward_year<- as.character(df$loanaward_year)

# separate categorical & continuous variables
# use sapply()
df.cat<-df[,sapply(df, is.character)]
colnames(df.cat)
df.cont<-df[,!sapply(df, is.character)]
colnames(df.cont)
df.1<- df[,c(colnames(df.cat),colnames(df.cont))]
colnames(df.1)

# Let's look at the distributions.
# For example, with categorical data, the distribution simply describes the proportion of each unique category.
# Distribution visualisation for categorical data: use Barplot
str(df.1)
colnames(df)

ggplot(data = df.1, aes(x= loan_purpose))+
  geom_bar()+
  labs(x="loan purpose", y = "count", title = "Why people take loans?")+
  theme_bw()

# barplot with two categorical variables
ggplot(data = df.1, aes(loan_purpose, ..count..))+
  geom_bar(aes(fill=loan.fund.sources), position = "dodge")+
  labs(x="loan purpose", y = "count", title = "Which loan reason attracts funding agency?")+
  theme_bw()

ggplot(data = df.1, aes(recipient.state))+
  geom_bar()+
  labs(x="loan purpose", y = "count", 
       title = "Which states give maximum loans?")+
  theme_bw()

# filter data for NY state and remove the recipient.state variable
df.1 <- df.1 %>%
  filter(recipient.state=='NY')
df.1$recipient.state<- NULL

# Individual feature visualisations
df.1 %>%
  group_by(loanaward_year) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= loanaward_year, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="loanaward year", y="Frequency",
       title = "Which year bagged maximum loans?")+
  coord_flip()+
  theme_bw()

df.1 %>%
  filter(original.loan.amount<=200000) %>%
  ggplot(aes(x = loanaward_year, y = original.loan.amount)) +
  geom_point(color = "darkorchid4") +
  labs(title = "Corporate Loans - NYC",
       subtitle = "Loans per year",
       y = "Loan amount",
       x = "Year") + theme_bw(base_size = 12)


# filter out data where amount repaid for startup's is greater than 10000
df.1 <- df.1 %>%
  filter(amount.repaid>=1 & amount.repaid<=54000)%>%
  filter(original.loan.amount <= 200000) %>%
  filter(loanaward_year>=2000)

# boxplot
ggplot(data = df.1)+
  geom_boxplot(aes(x= loan_purpose, y=original.loan.amount),
               outlier.color="red")+
  labs(x="loan purpose", y = "original loan amount", title = "Loan reason's vs Loan amount")+
  theme_bw()

ggplot(data = df.1)+
  geom_boxplot(aes(x= loan_purpose, y=amount.repaid),
               outlier.color="red")+
  labs(x="loan purpose", y = "amount repaid", title = "Loan purpose vs Loan amount repaid")+
  theme_bw()

colnames(df.1)
df.1 %>%
  group_by(recipient.city)%>%
  summarise(OriginalLoanAmt=sum(original.loan.amount))%>%
  arrange(OriginalLoanAmt)
  #ggplot(aes(recipient.city))+
  #geom_bar()

# CHECK FOR NEAR ZERO VARIANCE COLS
# Q. How many columns with near zero variance property?
badCols<- nearZeroVar(df.1)
dim(df.1[,badCols]) # [1] 3284    3
names(df.1[,badCols]) # [1] "new.jobs"      "fsYrEnd_month" "fsYrEnd_day"       "isFunded"     "isCollection" "paymt_min"    "paymt_sec"    "principal"
# remove the near zero variance predictors
df.1<- df.1[, -badCols]
dim(df.1) #[1] 3284 17

## Check for multicollinearity
library(corrplot)
cor1<- cor(df.1[,-c(1:10)])
corrplot(cor1, number.cex = .7) 

## Detecting skewed variables
skewedVars <- NA
for(i in names(df.1)){
  if(is.numeric(df.1[,i])){
    if(i != "xxx"){
      # Enters this block if variable is non-categorical
      skewVal <- skewness(df.1[,i])
      print(paste(i, skewVal, sep = ": "))
      if(abs(skewVal) > 0.5){
        skewedVars <- c(skewedVars, i)
      }
    }
  }
}
# No skewed variables found


### Supervised Feature Selection
library(caret)
set.seed(2021)
str(df.1)
colnames(df.1)
# calculate the correlation matrix
cor.mat<- cor(df.1[,c(13:20)])
# summarize the correlation matrix
print(cor.mat)
# find attributes that are highly corrected (ideally >0.75)
highlyCorrelated <- findCorrelation(cor.mat, cutoff=0.5, names = TRUE)
# print indexes of highly correlated attributes
print(highlyCorrelated)
colnames(df.1[,highlyCorrelated])
