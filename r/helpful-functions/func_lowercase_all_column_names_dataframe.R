# A function to lowercase all column names in a given dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}

# sample data
df<- data.frame(Gender=c("male","female","transgender"),
                Education=c("high-school","grad-school","home-school"),
                Smoke=c("yes","no","prefer not tell"))

colnames(df) # [1] "Gender"    "Education" "Smoke" 

# lowercase the column names
df1<- lowercase_cols(df)
colnames(df1) # [1] "gender"    "education" "smoke"  
