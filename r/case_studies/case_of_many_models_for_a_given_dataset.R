# Objective: Given a dataframe, create several models like linear regression, random forest etc and add these models to the dataframe itself.
# Something like Many Models concept (https://r4ds.had.co.nz/many-models.html)

library(modelr) # for add_predictions(), add_residuals()
library(tidyverse)
library(caret)
data <- read_csv("data/abalone.csv")

# random order the data
# set seed
set.seed(2020)
# Shuffle row indices: rows
rows = sample(nrow(data))
# Randomly order data
shuffled_data <- data[rows, ]

# data splitting
# Determine row to split on: split
split = round(nrow(shuffled_data)*.80)
# Create train
train = shuffled_data[1:split,]
# Create test
test = shuffled_data[(split + 1):nrow(shuffled_data), ]

# Fit lm model on train: model
model_rings_lm = lm(Rings~., train)

# Fit random forest model on train: model
# note: executing this code takes around 5 mins
model_rings_rf = train(
  Rings ~ ., 
  shuffled_data,
  method = "rf",
  trControl = trainControl(
    method = "cv", 
    number = 10,
    verboseIter = TRUE
  ))


train_preds<- train %>%
  # add predictions to train data
  add_predictions(model_rings, "rings_preds") %>%
  add_predictions(model_rings_rf, "rings_preds_CV") %>%
  # add residuals to the train data
  add_residuals(model_rings,"rings_resid")

ggplot(train_preds, aes(Rings, rings_preds_CV)) + 
  geom_hex(bins = 50) + 
  geom_line(colour = "red", size = 1)

# Many models example
# Create a nested data frame. To create a nested data frame we start with a grouped data frame, and “nest” it:
abalone_rings <- shuffled_data %>%
  group_by(Sex) %>%
  #add_predictions(model_rings_rf, "ring_pred_cv") %>%
  nest()
abalone_rings

# fit models on nested dataframes in the list
rings_model <- function(df) {
  lm(Rings ~ ., data = df)
}
#And we want to apply it to every data frame. The data frames are in a list, so we can use purrr::map() to apply country_model to each element:
models <- map(abalone_rings$data, rings_model) 
abalone_rings <- abalone_rings %>%
  mutate(model=map(data, rings_model))
abalone_rings %>%
  filter(Sex=="M")
# adding residuals
abalone_rings <- abalone_rings %>%
  mutate(
    resids = map2(data, model, add_residuals)
    )
abalone_rings
# And now unnest the list of dataframe
abalone_rings_models<- unnest(abalone_rings, resids)
# plot the residuals
abalone_rings_models %>% 
ggplot(aes(Height, resid)) +
  geom_line(aes(group = Rings), alpha = 1 / 3) + 
  geom_smooth(se = FALSE, method = "gam")

# Facetting by continent is particularly revealing:
abalone_rings_models %>% 
  ggplot(aes(Height, resid, group = "Rings")) +
  geom_line(aes(group = Sex), alpha = 1 / 3) +
  geom_line(alpha = 1 / 3) + 
  facet_wrap(~Sex)

# Getting model quality 
glance<- abalone_rings_models %>%
  mutate(glance = map(model, broom::glance)) %>% 
  unnest(glance)

glance %>% 
  arrange(r.squared)
glance %>% 
  ggplot(aes(Rings, r.squared)) + 
  geom_jitter(width = 0.5)

# remove rows with bad r-squared data
table(glance$r.squared)
bad_fit <- filter(glance, r.squared < 0.25)

shuffled_data %>% 
  #semi_join(bad_fit, by = "Rings") %>% 
  ggplot(aes(Diameter, Height, colour = Sex)) +
  geom_line()
