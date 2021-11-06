
# Pfizer data analysis

# clean workspace
rm(list = ls())
# required libraries
library(tidyverse)
library(lubridate) # for date functions
# read data in memory
df_ccs <- read.csv(file = "data/ccs.csv", sep = ",", na=c("",NA))
df_diag <- read.csv(file = "data/Diagnosis.csv", sep = ",", na=c("",NA))
df_pres <- read.csv(file = "data/Prescriptions.csv", sep = ",", na=c("",NA))

# check for missing values
sum(is.na(df_ccs)) # 0
sum(is.na(df_diag)) # 6
sum(is.na(df_pres)) # 0
colSums(is.na(df_diag)) # date has 6 missing values

# lowercase all column names
names(df_ccs)<- tolower(names(df_ccs))
names(df_diag)<- tolower(names(df_diag))
names(df_pres)<- tolower(names(df_pres))

# rename column name
# variable `diag` in diagnosis file is same as variable `icd10` in ccs file
colnames(df_ccs)[ colnames(df_ccs) == 'diag']<- 'icd10'
# inner join dataframes
df_ccsdiag <- inner_join(x=df_diag, y=df_ccs, by="icd10")
df_final <- inner_join(x=df_ccsdiag, y= df_pres, by= "patient_id")


# read df_final from disk
#df<- read_csv("data/pfizer_final.csv")
# colnames(df)
# head(df$diag_date)
# head(df$prescription_date)

# separate date into year,month format
df<- df_final
str(df)
# df<- df %>%
#   mutate(diags_date = ymd(diag_date),
#          diag_month = month(diags_date),
#          diag_day = day(diags_date),
#          diag_year = year(diags_date))
# df$diag_date<- NULL
# df$diags_date<- NULL
# 
# df<- df %>%
#   mutate(prescrp_date = ymd(prescription_date),
#          prescr_month = month(prescrp_date),
#          prescr_day = day(prescrp_date),
#          prescr_year = year(prescrp_date))
# df$prescription_date<- NULL
# df$prescrp_date<- NULL
# str(df)
# change data type
# colnames(df)
# l1<- names(df)[10:15]
# df[,l1]<- lapply(df[,l1], factor)
# df[,l1]<- lapply(df[,l1], as.numeric)
# df[,l1]<- lapply(df[,l1], factor)


# 
# table(df1$prescr_year) # prescription data year range: 2013-2018
# table(df1$diag_year) # diagnostics data year range: 2015-2018

# Filter and keep data for diags & prescrp year range 2015-2018
# df2 <- df1 %>%
#   filter(diag_year>=2015 & prescr_year>=2015)
# table(df2$diag_year, df2$prescr_year)
# write_csv(df2, file = "data/pfizer_2K1518.csv")
# 
# table(df2$diag_year, df2$diag_month)

# read the 2k1518 data for further analysis
# df<- read_csv(file = "data/pfizer_2K1518.csv")
# table(df_final$drug_class)
# 
# # count categoricals
# count(df_final, patient_id, icd10,diag_desc ,sort = TRUE) %>%
#   head(10)
# 
# df_two<- df_final %>%
#   #count(patient_id, icd10,diag_desc ,sort = TRUE)%>%
#   filter(str_detect( diag_desc, c("Salmonella","sclerosis"))) %>%
#   #filter(c("Salmonella","sclerosis") %in% diag_desc)%>%
#   mutate(two_disease = diag_desc %in% c("Salmonella","sclerosis"))
# 
# df_two %>%
#   count(patient_id, icd10,two_disease ,sort = TRUE)%>%
#   head(5)
# 
# table(df_two$two_disease)
# count(df_uterus, patient_id, icd10, sort = TRUE) %>%
#   head(5)
# 
# 
# # write to disk
# write_csv(df_final, file = "data/pfizer_final.csv", na = "NA")

# colnames(df)
# plots
# df%>%
#   filter(str_detect(ccs_3_desc, c("infection")))%>%
#   #mutate(pwi_cnt =  count(patient_id, sort = TRUE)) %>%
#   ggplot(aes(icd10))+
#   geom_bar()+
#   theme_bw()

##### 18/9
# read df_final from disk
# df<- read_csv("data/pfizer_final.csv")
# df<- df_final
colnames(df)
str(df)
# convert char dates to date
df$diag_date<- ymd(df$diag_date)
df$prescription_date<- ymd(df$prescription_date)
# convert date vars to date type
# df<- mutate_at(df, vars(starts_with("diag_")), funs(ymd))
# df<- mutate_at(df, vars(starts_with("prescription_")), funs(ymd))
range(df$diag_date) # year range 2015-2018
range(df$prescription_date) # year range 2013-2018
# Filter and keep data for diags & prescrp year range 2015-2018
df_2k15 <- df %>%
  filter(prescription_date>= "2015-02-01")

# rearrange vars
df_2k15<- df_2k15[,c(1,3:7,9:11,2,8)]
colnames(df_2k15)

df_2k15<-df_2k15 %>%
  group_by(patient_id, icd10) %>%
  #summarise(count = n_distinct(diag_date))
  mutate(diag_date_count = n_distinct(diag_date))%>%
  mutate(pres_date_count = n_distinct(prescription_date)) %>%
  arrange(desc(diag_date_count))

### NOW RESHAPE WIDE DATA TO LONG FORMAT
# https://stackoverflow.com/questions/12466493/reshaping-multiple-sets-of-measurement-columns-wide-format-into-single-columns
# x<- data.frame(V1 = names(df_2k15), V2=unname(t(df_2k15)))
# head(x)
# df_2k15 %>%
#   group_by(icd10) %>%
#   summarise(cnt = n()) %>%
#   arrange(cnt) %>%
#   ggplot(aes(reorder(x= icd10, -cnt, FUN=min), cnt))+
#   geom_point(size=4)+
#   labs(x="prescription month", y="Frequency",
#        title = "Which months have high prescriptions?")+
#   coord_flip()+
#   theme_bw()

# Q2. 

library(tidyverse)
library(lubridate)

df_pres <- read.csv(file = "data/Prescriptions.csv", sep = ",", na=c("",NA))
# lowercase col names
names(df_pres)<- tolower(names(df_pres)) 
# lowercase col values
df_pres = as.data.frame(sapply(df_pres, tolower)) 
# convert char to date
df_pres<- mutate_at(df_pres, vars(ends_with("_date")), funs(ymd))
# split date into separate cols
df_pres<- df_pres %>%
  mutate(pres_month = month(prescription_date),
         pres_day = day(prescription_date),
         pres_year = year(prescription_date))
# change data type
l1<- names(df_pres)[3:5]
df_pres[,l1]<- lapply(df_pres[,l1], factor)
df_pres[,l1]<- lapply(df_pres[,l1], as.numeric)
df_pres[,l1]<- lapply(df_pres[,l1], factor)


df_pres_grp<- df_pres %>%
  group_by(drug_class, drug_group) %>%
  filter(patient_id == max(patient_id)) %>%
  arrange(patient_id,desc(drug_category), .by_group = TRUE) 

# https://stackoverflow.com/questions/32766325/fastest-way-of-determining-most-frequent-factor-in-a-grouped-data-frame-in-dplyr
tmp<- df_pres %>%
  group_by(patient_id) %>%
  summarise(presc_count = names(table(drug_category))[which.max(table(drug_category))])%>%
  arrange(desc(presc_count))

colnames(df_pres)


# Plots
p<- ggplot(data = df_pres, aes(x=drug_category,fill=pres_year))
p+ geom_bar()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
colnames(df_pres)

df_pres %>%
  group_by(pres_month) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= pres_month, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="prescription month", y="Frequency",
       title = "Which months have high prescriptions?")+
  coord_flip()+
  theme_bw()


# table(df_pres_grp$pres_year)

# df_pres_grp <- as.data.frame(sapply(df_pres_grp,tolower))
# df_pres_grp <- df_pres_grp %>%
#   group_by(drug_category) %>%
#   mutate(disease_type = paste(unique(drug_category, drug_group),
#                               collapse = ','))



# df_2k15_grp<- df_2k15 %>%
#   group_by(drug_class, drug_group) %>%
#   filter(patient_id == max(patient_id)) %>%
#   arrange(patient_id,icd10)
# colnames(df_pres_grp)
# df_pres_grp<- df_pres_grp %>%
#   mutate(pres_month = month(prescription_date),
#          pres_day = day(prescription_date),
#          pres_year = year(prescription_date))

# 
# l1<- names(df_pres_grp)[3:5]
# df_pres_grp[,l1]<- lapply(df_pres_grp[,l1], factor)
# df_pres_grp[,l1]<- lapply(df_pres_grp[,l1], as.numeric)
# df_pres_grp[,l1]<- lapply(df_pres_grp[,l1], factor)
# str(df_pres_grp)

# df1$drug_category<- as.factor(as.numeric(factor(df1$drug_category)))
# df1$drug_group<- as.factor(as.numeric(factor(df1$drug_group)))
# df1$drug_class<- as.factor(as.numeric(factor(df1$drug_class)))

### 19/Sep
range(df_pres$prescription_date)
ggplot(data = df_pres, aes(x=prescription_date, y= drug_class))+
  geom_bar(stat = "identity")

df<- df_pres
colnames(df)
table(df$pres_year, df$pres_month)
# filter out incomplete data only
df<- df %>%
  filter(pres_year>2013 & pres_year<2018)

# 
patient_high_prescr_count <- df %>%
  count(patient_id, drug_category) %>%
  arrange(desc(n)) %>%
  group_by(drug_category) %>%
  slice(seq_len(3))

high_pres_year <- df %>%
  count(patient_id, pres_year) %>%
  arrange(desc(n))
  

# Plots
p<- ggplot(data = df, aes(x=pres_year))
p + geom_bar()+
  theme_bw()
colnames(df)
