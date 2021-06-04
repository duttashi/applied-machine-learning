# Analysis objective: To explore the salary distribution
# Possible hypothesis to check are;
# 1. Salary depends on profession type

rm(list = ls())

# required libraries
library(tidyverse)
library(tidytext)

# Exploratory Data Analysis
df<- read_csv("data/kaggle_sfsalaries.csv", na = c("", NA))
str(df)
dim(df) # 148654 rows 13 cols
sum(is.na(df)) # 446579 missing values
colSums(is.na(df)) # vars benefits, status, notes are completely blank. remove them from further analysis

# drop all blank cols
df$Notes<- NULL
df$Agency<- NULL # static with only 1 value

# Tidy text cleaning
# JobTile: Extract single word detailing the job title

df_clean<-df %>%
  # lowercase all character variables
  mutate(across(where(is.character), tolower))%>%
  filter(!str_detect(JobTitle,"\\W")) %>%
  #group_by(JobTitle)%>%
  arrange(desc(JobTitle))

# filter jobtitles with count >= 100
df_top100_JT<- df_clean %>%
  group_by(JobTitle) %>%
  filter(n()>=100)

colSums(is.na(df_top100_JT))
df_top100_JT %>%
  # filter out missing values in BasePay 
  filter(!is.na(BasePay)) %>%
  ggplot(., aes(x=JobTitle, y=BasePay))+
  geom_boxplot(outlier.color = "red")+
  #geom_bar()+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, size=15, 
                                   hjust = 1),
        #plot.background = element_rect(fill =  "pink"),
        panel.background = element_rect(fill = "lightblue",
                                        colour = "lightblue",
                                        size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                        colour = "white"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                        colour = "white"))
        
        
  

table(df_clean$JobTitle)
df_clean %>% 
  # arrange(desc(JobTitle)) %>%
  #slice_min(JobTitle, n=20) %>%
  #top_n(5)
  #ggplot(., aes(x=BasePay, y=JobTitle))+
  ggplot(., aes(x=JobTitle))+
  #geom_boxplot()+
  geom_bar()+
  theme(axis.text.x = element_text(angle = 45, size=15, hjust = 1))

  # anti_join(stop_words, by= c("JobTitle" = "word"))%>%
  # #unnest_tokens(JobTitle, text)
  # #filter(str_detect(str_to_lower(JobTitle),"[a-zA-Z]"))
  # unnest_tokens(word, JobTitle) 
# anti_join(get_stopwords()) %>%
  # mutate(JobTitle_Count = count(word))
  #mutate(word_count = count(word))


# names(df)
# corp <- Corpus(DataframeSource(df$JobTitle)) 
# # Error in DataframeSource(df$JobTitle) : 
# #   all(!is.na(match(c("doc_id", "text"), names(x)))) is not TRUE
# 
# # What the error means: 
# wa# its looking for a column named doc_id and a column named text, and didn’t find them in your dataframe”. As the documentation for DataframeSource mentions: “The first column must be named ‘doc_id’ and contain a unique string identifier for each document. The second column must be named ‘text’”. It’s probably easiest to use country_code as our unique id variable, so we rename that column to doc_id, and we’re good:
#   
# names(df)[1]<- "doc_id"
# docs <- tm_map(corp, removePunctuation)
# docs <- tm_map(docs, removeNumbers) 
# docs <- tm_map(docs, tolower)
# docs <- tm_map(docs, removeWords, stopwords("spanish"))
# docs <- tm_map(docs, stemDocument, language = "spanish") 
# docs <- tm_map(docs, PlainTextDocument) 
# dtm <- DocumentTermMatrix(docs)   
# dtm  
# 
# 
# # Feature Engineering
# job_type_legal<- 'police|fire|sheriff|attorney|lawyer|judge|auditor|inspector'
# job_type_health<- 'nursing|nurse|physician|anethist|forensic|doctor'
# job_type_manufc<- 'building|bricklayer|contract|architect|architecturalengineer|landscape|design|designer|technician'
# job_type_admn<- 'adm|admin|administrative|administrator|clerk|assessor'
# job_type_secur<- 'security|guard'
# job_type_edu<- 'instructor'
# job_type_animal<- 'animal|aquatics|aquatic'
# job_type_ojt<- 'apprentice|intern'
# # create new variables. Assign boolean value basis of other cols
# df<- df %>%
#   # lowercase all character variables
#   mutate(across(where(is.character), tolower))%>%
#   # create new logical colum from jobTitle type col
#   mutate(job_lgl = str_detect(JobTitle, job_type_legal))%>%
#   mutate(job_hlth = str_detect(JobTitle, job_type_health))%>%
#   mutate(job_manuf = str_detect(JobTitle, job_type_manufc))%>%
#   mutate(job_admin = str_detect(JobTitle, job_type_admn))%>%
#   mutate(job_securty = str_detect(JobTitle, job_type_secur))%>%
#   mutate(job_edu = str_detect(JobTitle, job_type_edu))%>%
#   mutate(job_ojt = str_detect(JobTitle, job_type_ojt))
# 
# table(df$job_lgl)
# table(df$job_admin)
# table(df$job_securty)
# table(df$job_ojt)
