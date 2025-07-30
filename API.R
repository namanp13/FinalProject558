# Loading libraries
library(caret)
library(plumber)
library(readr)
library(dplyr)

# Loading data
diabetes_data <- read_csv("diabetes_012_health_indicators_BRFSS2015.csv") |>
  mutate(
    Diabetes_binary = factor(if_else(Diabetes_012 == 0, "No", "Yes")),
    PhysActivity = factor(PhysActivity, labels = c("No", "Yes")),
    HighBP = factor(HighBP, labels = c("No", "Yes"))
  )

# Fitting the best model (logistic regression)
set.seed(123)

best_model <- train(Diabetes_binary ~ BMI + PhysActivity + HighBP, data = diabetes_data, method = "glm", family = "binomial", trControl = trainControl(method = "cv", number = 5, classProbs = TRUE, summaryFunction = mnLogLoss), metric = "logLoss")

# Setting the default values (mean for numeric, majority for categorical)
default_BMI <- mean(diabetes_data$BMI, na.rm = TRUE)
default_PhysActivity <- names(which.max(table(diabetes_data$PhysActivity)))
default_HighBP <- names(which.max(table(diabetes_data$HighBP)))

#* Predicting diabetes probability
#* @param BMI Body Mass Index (numeric)
#* @param PhysActivity Physically active? ("Yes"/"No")
#* @param HighBP High blood pressure? ("Yes"/"No")
#* @get /pred
function(BMI = default_BMI,
         PhysActivity = default_PhysActivity,
         HighBP = default_HighBP) {
  
  input <- data.frame(
    BMI = as.numeric(BMI), PhysActivity = factor(PhysActivity, levels = c("No", "Yes")), HighBP = factor(HighBP, levels = c("No", "Yes"))
  )
  
  probs <- predict(best_model, newdata = input, type = "prob")
  list(prob_diabetes = probs$Yes)
}

#Three example function calls to try:
# http://127.0.0.1:35363/pred?BMI=28.3824&PhysActivity=Yes&HighBP=No
# http://127.0.0.1:35363/pred?BMI=35&PhysActivity=Yes&HighBP=Yes
# http://127.0.0.1:35363/pred?BMI=57&PhysActivity=Yes&HighBP=No

#* API Author Info
#* @get /info
function() {
  list(
    name = "Naman Pujani",
    github_pages = "https://namanp13.github.io/FinalProject558/"
  )
}

