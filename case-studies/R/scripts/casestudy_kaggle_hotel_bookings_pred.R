# Objective: Have you ever wondered when the best time of year to book a hotel room is? Or the optimal length of stay in order to get the best daily rate? What if you wanted to predict whether or not a hotel was likely to receive a disproportionately high number of special requests?
# Evaluation metric # 
# Dependent variable # 
# reference # https://www.kaggle.com/jessemostipak/hotel-booking-demand
# reference: https://juliasilge.com/blog/hotels-recipes/


# required libraries
library(tidyverse)
library(tidymodels)
library(GGally)
library(caret)
library(rpart)
library(rpart.plot)
library(corrplot)

# clean the workspace
rm(list = ls())
# read data in memory
hotels<- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-11/hotels.csv")

# Exploratory data analysis
# Visualize the imbalanced data
hotels %>%
  dplyr::filter(!is.na(is_canceled)) %>%
  ggplot(aes(x=as.factor(is_canceled)))+
  geom_bar()+
  ggtitle("Imbalanced class distribution")+
  labs(x="hotel booking", y="count")+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))

skim(hotels)
hotel_stays <- hotels %>%
  filter(is_canceled == 0) %>%
  mutate(
    children = case_when(
      children + babies > 0 ~ "children",
      TRUE ~ "none"
    ),
    required_car_parking_spaces = case_when(
      required_car_parking_spaces > 0 ~ "parking",
      TRUE ~ "none"
    )
  ) %>%
  select(-is_canceled, -reservation_status, -babies)

hotel_stays %>%
  count(children)
# How do the hotel stays of guests with/without children vary throughout the year? Is this different in the city and the resort hotel?
hotel_stays %>%
  mutate(arrival_date_month = factor(arrival_date_month,
                                     levels = month.name
  )) %>%
  count(hotel, arrival_date_month, children) %>%
  group_by(hotel, children) %>%
  mutate(proportion = n / sum(n)) %>%
  ggplot(aes(arrival_date_month, proportion, fill = children)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_wrap(~hotel, nrow = 2) +
  labs(
    x = NULL,
    y = "Proportion of hotel stays",
    fill = NULL
  )+
  theme_bw()
# Are hotel guests with children more likely to require a parking space?
hotel_stays %>%
  count(hotel, required_car_parking_spaces, children) %>%
  group_by(hotel, children) %>%
  mutate(proportion = n / sum(n)) %>%
  ggplot(aes(required_car_parking_spaces, proportion, fill = children)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_wrap(~hotel, nrow = 2) +
  labs(
    x = NULL,
    y = "Proportion of hotel stays",
    fill = NULL
  )+
  theme_bw()
# I like to use the ggpairs() function to get a high-level view of how variables are related to each other.
#install.packages("GGally", dependencies = TRUE)

hotel_stays %>%
  select(
    children, adr,
    required_car_parking_spaces,
    total_of_special_requests
  ) %>%
  ggpairs(mapping = aes(color = children))+
  theme_bw()
#  create a dataset for modeling. Let’s include a set of columns we are interested in, and convert all the character columns to factors, for the modeling functions coming later.
hotels_df <- hotel_stays %>%
  select(
    children, hotel, arrival_date_month, meal, adr, adults,
    required_car_parking_spaces, total_of_special_requests,
    stays_in_week_nights, stays_in_weekend_nights
  ) %>%
  mutate_if(is.character, factor)

#install.packages("tidymodels", dependencies = TRUE)


set.seed(1234)
hotel_split <- initial_split(hotels_df)

hotel_train <- training(hotel_split)
hotel_test <- testing(hotel_split)

hotel_rec <- recipe(children ~ ., data = hotel_train) %>%
  step_downsample(children) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_zv(all_numeric()) %>%
  step_normalize(all_numeric()) %>%
  prep()

hotel_rec
