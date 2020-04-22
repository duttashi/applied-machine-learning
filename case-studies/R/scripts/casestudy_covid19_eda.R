# competition hosted on: https://www.crowdanalytix.com/contests/covid-19-research-contest
# Objective: The objective of this contest is to derive information from the CORD-19 dataset via text mining / NLP / ML approaches to visualize and present data in an intuitive manner. 
# data location: https://pages.semanticscholar.org/coronavirus-research
# dataset I have used: Non-commercial use subset 41 MB

# required libraries
library(purrr)
library(rjson)

# read the covid19 research papers
getwd()
data_path<- "data/covid19"
files <- dir(data_path, pattern = "*.json")

# read the json files to a list
json_file_list <- list.files(data_path, pattern = "*.json", full.names = TRUE)

# read the json list to a json object
df<- purrr::map_df(json_file_list, function(x) { 
  purrr::map(jsonlite::fromJSON(x, flatten = TRUE), function(y) ifelse(is.null(y), NA, y)) 
})

# Transform to dataframes
colnames(df)
df_1<- df[,colnames(df)]
str(df_1)

# First coerce the data.frame to all-character
df_1 = data.frame(lapply(df, as.character), stringsAsFactors=FALSE)

# write to disc
?write.csv
write.csv(df_1, file = "data/covid19/covid19_data.csv")


