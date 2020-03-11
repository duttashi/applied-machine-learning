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
# variable age is same as in season_goals data. So drop it from game_goals data
# replace blanks in var "at" with home, "@" with oppo_arena
# recode factor levels in variable outcome
game_goals$age<- NULL
game_goals<- game_goals %>%
  separate(date, c("game_year","game_month","game_date"),sep = "-")
# change data type
game_goals$game_year<- as.numeric(game_goals$game_year)
game_goals$game_month<- as.numeric(game_goals$game_month)
game_goals$game_date<- as.numeric(game_goals$game_date)

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
# change data type
season_goals$season_start_year<- as.numeric(season_goals$season_start_year)
season_goals$season_end_year<- as.numeric(season_goals$season_end_year)
season_goals$year_start<- as.numeric(season_goals$year_start)
season_goals$year_end<- as.numeric(season_goals$year_end)
# drop yr_start, headshot
season_goals$yr_start<- NULL
season_goals$headshot<- NULL

str(top_250) 
# Observations
# split variable, years into year_start, year_end
# remove url_number and url_link raw_link,link,yr_start
top_250<- top_250 %>%
  separate(years, c("top250year_start","top250year_end"), sep = "-")
top_250$url_number<-NULL
top_250$raw_link<-NULL
top_250$link<-NULL
top_250$yr_start<-NULL
# replace values greater than 70 in year_end with 19 followed by value
top_250<- top_250 %>%
  mutate(top250year_end = case_when(top250year_end>=70 ~ paste0("19", top250year_end),
                                    top250year_end<=20 ~ paste0("20", top250year_end),
                              TRUE ~ top250year_end))
# change data type
top_250$top250year_start<- as.numeric(top_250$top250year_start)
top_250$top250year_end<- as.numeric(top_250$top250year_end)

# write clean data to disk
write.csv(game_goals, file = "data/game_goals.csv")
write.csv(season_goals, file = "data/season_goals.csv")
write.csv(top_250, file = "data/top_250_goals.csv")

# player is present in all tables. So can joj them together
# join the data frames
x.dat<- full_join(season_goals, top_250)
df<- full_join(x.dat, game_goals)
# convert all character cols into factor
str(df)
df[sapply(df, is.character)]<- lapply(df[sapply(df, is.character)],
                                                     as.factor)
# recode the factor levels
levels(df$outcome)
df$outcome <- forcats::fct_collapse(df$outcome, 'game_lost'=c("L"),'game_lost'=c("L-OT"),
                        'game_lost'=c("L-SO"),'game_tie'=c("T"),
                        'game_won'=c("W")
                        )
df$position<- forcats::fct_collapse(df$position, 'center_pos'=c("C"),'rightwing_pos'=c("RW"),
                                    'leftwing_pos'=c("LW"),'undefined_pos'=c("D")
                                    )
# remove var active because another variable status has same values as active
df$active<- NULL
df$age_in_years<- NULL
# rearrange cols such that factor are first followed by numeric
df<- df[,c(2:4,8,12:13,32:35,1, 5:7,9:11,14:31,36:43)]

# write merged data to disk
write.csv(df, file = "data/merged_games_data.csv")

# remove the temporary data frames
rm(x.dat)

# Visualizations
# reference: 
str(df)

# Correlation: scatterplot, scatterplot with encircling

data(mtcars)
str(mtcars)

mtcars %>%
  select(mpg,cyl,disp)
# scatterplot
str(df)
table(df$season_start_year)
df %>%
  select(position, hand,player,status,team,league,outcome,rank,
         total_goals, season_start_year,season_end_year,season_games, age)%>%
  #filter(!is.na(status) & !is.na(total_goals))%>%
  filter(season_start_year>=2010) %>%
  ggplot(aes(x=total_goals))+
  #filter(!is.na(position))
  #geom_area(stat = "bin", binwidth=200)
  #geom_area(aes(y=..density..),stat = "bin",binwidth=200)
  #geom_smooth(method = "lm", se=FALSE)
  geom_density(aes(fill=status),na.rm = TRUE, show.legend = TRUE)+
  theme_bw()
# Deviation; diverging bars, area chart

# Ranking: ordered bar chart

# Distribution: histogram, boxplot, density plot, dot+box plot, 

df %>%
  group_by(total_goals)%>%
  filter(!is.na(total_goals))%>%
  ggplot(aes(x=status, y=total_goals))+
  geom_boxplot(outlier.colour = "red", na.rm = TRUE, position = "dodge")+
  ggtitle("(a) Goal count ")+
  labs(x="Players in/action", y="total goals")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

df %>%
  group_by(total_goals)%>%
  filter(!is.na(total_goals))%>%
  ggplot(aes(x=position, y=total_goals))+
  geom_boxplot(outlier.colour = "red", na.rm = TRUE, position = "dodge")+
  #geom_smooth(method = "lm", se=FALSE, color="black",aes(group=1))+
  ggtitle("(a) Player position and goals ")+
  labs(x="Players position", y="total goals")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

df %>%
  group_by(total_goals)%>%
  filter(!is.na(total_goals))%>%
  #filter(!is.na(location))%>%
  ggplot(aes(x=hand, y=total_goals, fill= league))+
  geom_boxplot(outlier.colour = "red", na.rm = TRUE, position = "dodge")+
  geom_smooth(method = "lm", se=FALSE, color="black",aes(group=1))+
  ggtitle("(c) Player dominant hand and goals ")+
  labs(x="hand", y="total goals")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

df %>%
  group_by(season_games)%>%
  filter(!is.na(season_games))%>%
  ggplot(aes(x=season_games, y=total_goals, fill= league))+
  geom_point() + 
  stat_summary(fun.y = mean, geom = "line", color="red",aes(group = 1))

str(df)


# dimensionality reduction
# 1. Remove cols with more than 80% missing data
# approach #1
# df_reduced<- df[ lapply( df, function(x) sum(is.na(x)) / length(x) ) >= 0.80 ]
# names(df_reduced)
# df_reduced$player<- df$player # add the play column back to the reduced dataframe
# df_reduced$outcome<- df$outcome
# df_reduced$team<- df$team
# df_reduced$game_year<- df$game_year
# 
# # approach #2
# #df_reduced<- df[,colMeans(is.na(df))>= 0.80]
# colSums(is.na(df_reduced))
# # drop column "active' as it has same values in it as the column status
# df_reduced$active<- NULL

# library(VIM)
# aggr(df_reduced, col=c('navyblue','yellow'),
#      numbers=TRUE, sortVars=TRUE,
#      labels=names(df_reduced), cex.axis=.7,
#      gap=3, ylab=c("Missing data","Pattern"))

df_cmplt<- df %>%
  drop_na()


# 1. Relationship between player age and total goals
str(df)
table(df$outcome)

df %>%
  group_by(age, total_goals, outcome) %>%
  filter(!is.na(total_goals))%>%
  filter(!is.na(points))%>%
  #filter(!is.na(outcome))%>%
  ggplot(aes(x=total_goals, y=points))+
  #geom_boxplot(outlier.colour = "red", na.rm = TRUE, alpha=0.2)+
  geom_point()+
  #geom_line()+
  theme_bw()
