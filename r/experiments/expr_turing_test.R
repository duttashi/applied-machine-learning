
library(readr)
# load data
df_calco<- read_csv(file = "data/cardio_alco.csv")
df_cbase<- read_csv(file = "data/cardio_base.csv")
df_covid_data<- read_csv(file = "data/covid_data.csv")

str(df_cbase)