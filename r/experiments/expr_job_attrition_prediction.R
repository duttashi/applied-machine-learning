
# Reference: https://www.kaggle.com/arashnic/hr-analytics-job-change-of-data-scientists/tasks

# required libraries
library(dplyr) # for data manipulation
library(mice) # for missing data imputation
library(ggplot2)

# read the data
df_train<- read.csv("data/aug_train.csv", 
                    stringsAsFactors = F, na.strings = c("",NA))
df_test <- read.csv("data/aug_test.csv", stringsAsFactors = F,
                    na.strings = c("",NA))
# sum(is.na(df_train))
# colSums(is.na(df_train))
# colSums(is.na(df_test))
# colnames(df_train)
# colnames(df_test)

### combines data frames (like rbind) but by matching column names
# columns without matches in the other data frame are still combined
# but with NA in the rows corresponding to the data frame without
# the variable
# A warning is issued if there is a type mismatch between columns of
# the same name and an attempt is made to combine the columns
combineByName <- function(A,B) {
  a.names <- names(A)
  b.names <- names(B)
  all.names <- union(a.names,b.names)
  print(paste("Number of columns:",length(all.names)))
  a.type <- NULL
  for (i in 1:ncol(A)) {
    a.type[i] <- typeof(A[,i])
  }
  b.type <- NULL
  for (i in 1:ncol(B)) {
    b.type[i] <- typeof(B[,i])
  }
  a_b.names <- names(A)[!names(A)%in%names(B)]
  b_a.names <- names(B)[!names(B)%in%names(A)]
  if (length(a_b.names)>0 | length(b_a.names)>0){
    print("Columns in data frame A but not in data frame B:")
    print(a_b.names)
    print("Columns in data frame B but not in data frame A:")
    print(b_a.names)
  } else if(a.names==b.names & a.type==b.type){
    C <- rbind(A,B)
    return(C)
  }
  C <- list()
  for(i in 1:length(all.names)) {
    l.a <- all.names[i]%in%a.names
    pos.a <- match(all.names[i],a.names)
    typ.a <- a.type[pos.a]
    l.b <- all.names[i]%in%b.names
    pos.b <- match(all.names[i],b.names)
    typ.b <- b.type[pos.b]
    if(l.a & l.b) {
      if(typ.a==typ.b) {
        vec <- c(A[,pos.a],B[,pos.b])
      } else {
        warning(c("Type mismatch in variable named: ",all.names[i],"\n"))
        vec <- try(c(A[,pos.a],B[,pos.b]))
      }
    } else if (l.a) {
      vec <- c(A[,pos.a],rep(NA,nrow(B)))
    } else {
      vec <- c(rep(NA,nrow(A)),B[,pos.b])
    }
    C[[i]] <- vec
  }
  names(C) <- all.names
  C <- as.data.frame(C)
  return(C)
}

# combine train and test set
df<- combineByName(df_train, df_test)
