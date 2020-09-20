# Q. How to convert many character columns to numeric
# required libraries: dplyr, plyr, magritrr

# sample data
df<- data.frame(gender=c("male","female","transgender"),
                education=c("high-school","grad-school","home-school"),
                smoke=c("yes","no","prefer not tell"))
print(df)
# gender   education           smoke
# 1        male high-school             yes
# 2      female grad-school              no
# 3 transgender home-school prefer not tell

convert_many_character_vars_to_numeric<- function(df){
  # I asked this Q on SO: https://stackoverflow.com/questions/63947875/how-to-elegantly-recode-multiple-columns-containing-multiple-values/63947908?noredirect=1#comment113080985_63947908
  df1<- df %>% 
    # Coerce all character formats to Factors
    mutate(across(gender:smoke,~as.factor(.))) %>%
    mutate(across(gender:smoke,~factor(.,levels = unique(.)))) %>%
    # Coerce all factors to numeric
    mutate(across(gender:smoke,~as.numeric(.)))
  return(df1)
}

library(tidyverse)
# function test
df_new<- convert_many_character_vars_to_numeric(df)
print(df_new)
# gender education smoke
# 1      1         1     1
# 2      2         2     2
# 3      3         3     3