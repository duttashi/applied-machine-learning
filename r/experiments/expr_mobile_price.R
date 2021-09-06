library(readr)
df<- read.csv("data/av_crossell_pred_train.csv",na=c("",NA))
colSums(is.na(df))
