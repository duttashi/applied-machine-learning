
# data source url: https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-03-03
# objective: Exploratory Data Analysis

# clean the workspace
rm(list = ls())

# load required libraries
library(tidyverse)

# Get the Data
game_goals <- data.frame(read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/game_goals.csv'))

top_250 <- data.frame(read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/top_250.csv'))

season_goals <- data.frame(read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/season_goals.csv'))

# Exploratory Data Analysis (EDA)
str(game_goals) 
# Observations for game_goals data
# split age column into age_years and age_days
# replace blanks in var "at" with home, "@" with oppo_arena
game_goals<- game_goals %>%
  separate(age, c("age_in_years","age_in_days"),sep = "-")
game_goals<- game_goals %>%
  separate(date, c("game_year","game_month","game_date"),sep = "-")
game_goals <- game_goals %>%
  mutate(at=replace(at, at=="@","oppo"))
game_goals <- game_goals %>%
  mutate(at=replace(at, which(is.na(at)),"home"))

str(season_goals) 
# Observations
# split variable, season into season_start, season_end
# split variable, years into year_start, year_end
season_goals<- season_goals %>%
  separate(season, c("season_start_year","season_end_year"),sep = "-")
season_goals<- season_goals %>%
  separate(years, c("year_start","year_end"), sep = "-")
# replace values greater than 70 in year_end with 19 followed by value
season_goals<- season_goals %>%
  mutate(year_end = case_when(year_end>=70 ~ paste0("19", year_end),
                              year_end<=20 ~ paste0("20", year_end),
                              TRUE ~ year_end))
season_goals<- season_goals %>%
  mutate(season_end_year = case_when(season_end_year>=70 ~ paste0("19", season_end_year),
                                     season_end_year<=20 ~ paste0("20", season_end_year),
                              TRUE ~ season_end_year))
# drop yr_start, headshot
season_goals$yr_start<- NULL
season_goals$headshot<- NULL


str(top_250) 
# Observations
# split variable, years into year_start, year_end
# remove url_number and url_link raw_link,link,yr_start
top_250<- top_250 %>%
  separate(years, c("year_start","year_end"), sep = "-")
top_250$url_number<-NULL
top_250$raw_link<-NULL
top_250$link<-NULL
top_250$yr_start<-NULL
# replace values greater than 70 in year_end with 19 followed by value
top_250<- top_250 %>%
  mutate(year_end = case_when(year_end>=70 ~ paste0("19", year_end),
                              year_end<=20 ~ paste0("20", year_end),
                              TRUE ~ year_end))

# write clean data to disk
write.csv(game_goals, file = "data/game_goals.csv")
write.csv(season_goals, file = "data/season_goals.csv")
write.csv(top_250, file = "data/top_250_goals.csv")

# player is present in all tables. So can joj them together
# find common cols between data frames
intersect(colnames(game_goals), colnames(season_goals))

# join the data frames
x.dat<- full_join(season_goals, top_250)
df<- full_join(x.dat, game_goals)
# remove the temporary data frames
rm(x.dat)

# write merged data to disk
write.csv(df, file = "data/merged_games_data.csv")

# EDA
str(df)
colSums(is.na(df))

# dimensionality reduction
# 1. Remove cols with more than 80% missing data
# approach #1
df_reduced<- df[ lapply( df, function(x) sum(is.na(x)) / length(x) ) >= 0.80 ]
df_reduced$player<- df$player # add the play column back to the reduced dataframe
# approach #2
#df_reduced<- df[,colMeans(is.na(df))>= 0.80]
colSums(is.na(df_reduced))
str(df_reduced)

# EDA
# coerce all character cols to factor
df_reduced[sapply(df_reduced, is.character)]<- lapply(df_reduced[sapply(df_reduced, is.character)],
                                                      as.factor)
str(df_reduced)
