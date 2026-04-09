# ============================================================
# LOAN APPROVAL PREDICTION - Complete ML Project in R
# Dataset: Loan Prediction Problem Dataset (Kaggle)
# ============================================================

# ============================================================
# STEP 1: INSTALL AND LOAD REQUIRED LIBRARIES
# ============================================================

# Fix for Windows: use a personal library folder (avoids admin permission errors)
personal_lib <- file.path(Sys.getenv("USERPROFILE"), "R", "library")
if (!dir.exists(personal_lib)) dir.create(personal_lib, recursive = TRUE)
.libPaths(c(personal_lib, .libPaths()))

# Run this block once to install all required packages
packages <- c("tidyverse", "caret", "rpart", "rpart.plot",
              "randomForest", "e1071", "ggplot2", "corrplot",
              "gridExtra", "dplyr", "mice")

installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed], lib = personal_lib)
}

library(tidyverse)
library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)
library(e1071)
library(ggplot2)
library(corrplot)
library(gridExtra)
library(dplyr)
library(mice)

cat("All libraries loaded successfully!\n")


# ============================================================
# STEP 2: LOAD THE DATASET
# ============================================================
# Download train.csv from Kaggle and place it in your working directory.
# Link: https://www.kaggle.com/datasets/altruistdelhite04/loan-prediction-problem-dataset

# Set working directory to the folder where train.csv is saved
# setwd("C:/Users/YourName/loan_project")   # <-- Change this path

loan_data <- read.csv("train.csv", stringsAsFactors = TRUE)

cat("\n--- Dataset Overview ---\n")
cat("Rows:", nrow(loan_data), "\n")
cat("Columns:", ncol(loan_data), "\n")

cat("\n--- First 6 Rows ---\n")
print(head(loan_data))

cat("\n--- Column Names ---\n")
print(names(loan_data))

cat("\n--- Structure ---\n")
str(loan_data)

cat("\n--- Summary Statistics ---\n")
print(summary(loan_data))


# ============================================================
# STEP 3: EXPLORATORY DATA ANALYSIS (EDA)
# ============================================================

cat("\n--- Missing Values Per Column ---\n")
missing_vals <- colSums(is.na(loan_data))
print(missing_vals[missing_vals > 0])

# --- Plot 1: Loan Status Distribution ---
p1 <- ggplot(loan_data, aes(x = Loan_Status, fill = Loan_Status)) +
  geom_bar() +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Approval Status Distribution",
       x = "Loan Status", y = "Count") +
  theme_minimal()

# --- Plot 2: Loan Status by Gender ---
p2 <- ggplot(loan_data %>% filter(!is.na(Gender)),
             aes(x = Gender, fill = Loan_Status)) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Status by Gender", x = "Gender", y = "Count") +
  theme_minimal()

# --- Plot 3: Loan Status by Education ---
p3 <- ggplot(loan_data, aes(x = Education, fill = Loan_Status)) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Status by Education", x = "Education", y = "Count") +
  theme_minimal()

# --- Plot 4: Loan Status by Credit History ---
p4 <- ggplot(loan_data %>% filter(!is.na(Credit_History)),
             aes(x = as.factor(Credit_History), fill = Loan_Status)) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Status by Credit History",
       x = "Credit History (1=Good, 0=Bad)", y = "Count") +
  theme_minimal()

grid.arrange(p1, p2, p3, p4, ncol = 2)

# --- Plot 5: Applicant Income Distribution ---
p5 <- ggplot(loan_data, aes(x = ApplicantIncome, fill = Loan_Status)) +
  geom_histogram(bins = 40, alpha = 0.7, position = "identity") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Applicant Income Distribution by Loan Status",
       x = "Applicant Income", y = "Count") +
  theme_minimal()

# --- Plot 6: Loan Amount Distribution ---
p6 <- ggplot(loan_data %>% filter(!is.na(LoanAmount)),
             aes(x = LoanAmount, fill = Loan_Status)) +
  geom_histogram(bins = 40, alpha = 0.7, position = "identity") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Amount Distribution by Loan Status",
       x = "Loan Amount", y = "Count") +
  theme_minimal()

grid.arrange(p5, p6, ncol = 2)

# --- Plot 7: Marital Status vs Loan Status ---
p7 <- ggplot(loan_data %>% filter(!is.na(Married)),
             aes(x = Married, fill = Loan_Status)) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Approval Rate by Marital Status",
       x = "Married", y = "Proportion") +
  theme_minimal()

# --- Plot 8: Property Area vs Loan Status ---
p8 <- ggplot(loan_data, aes(x = Property_Area, fill = Loan_Status)) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = c("Y" = "#4CAF50", "N" = "#F44336")) +
  labs(title = "Loan Approval Rate by Property Area",
       x = "Property Area", y = "Proportion") +
  theme_minimal()

grid.arrange(p7, p8, ncol = 2)


# ============================================================
# STEP 4: DATA PREPROCESSING
# ============================================================

# 4a. Remove Loan_ID column (not useful for prediction)
loan_data$Loan_ID <- NULL

# 4b. Handle Missing Values using mode/median imputation
# Mode function
get_mode <- function(x) {
  ux <- unique(x[!is.na(x)])
  ux[which.max(tabulate(match(x, ux)))]
}

# Impute categorical columns with mode
loan_data$Gender[is.na(loan_data$Gender)]           <- get_mode(loan_data$Gender)
loan_data$Married[is.na(loan_data$Married)]         <- get_mode(loan_data$Married)
loan_data$Dependents[is.na(loan_data$Dependents)]   <- get_mode(loan_data$Dependents)
loan_data$Self_Employed[is.na(loan_data$Self_Employed)] <- get_mode(loan_data$Self_Employed)
loan_data$Credit_History[is.na(loan_data$Credit_History)] <- get_mode(loan_data$Credit_History)

# Impute numerical columns with median
loan_data$LoanAmount[is.na(loan_data$LoanAmount)]               <- median(loan_data$LoanAmount, na.rm = TRUE)
loan_data$Loan_Amount_Term[is.na(loan_data$Loan_Amount_Term)]   <- median(loan_data$Loan_Amount_Term, na.rm = TRUE)

cat("\n--- Missing Values After Imputation ---\n")
print(colSums(is.na(loan_data)))

# 4c. Feature Engineering — Log Transform for skewed numeric columns
loan_data$LoanAmount_log     <- log(loan_data$LoanAmount + 1)
loan_data$ApplicantIncome_log <- log(loan_data$ApplicantIncome + 1)
loan_data$CoapplicantIncome_log <- log(loan_data$CoapplicantIncome + 1)

# 4d. Encode Credit_History as factor
loan_data$Credit_History <- as.factor(loan_data$Credit_History)

cat("\n--- Data After Preprocessing ---\n")
str(loan_data)

# 4e. Correlation Plot for numeric features
numeric_cols <- loan_data %>% select_if(is.numeric)
corr_matrix  <- cor(numeric_cols)
corrplot(corr_matrix, method = "color", type = "upper",
         tl.cex = 0.8, title = "Correlation Matrix of Numeric Features",
         mar = c(0, 0, 2, 0))


# ============================================================
# STEP 5: TRAIN-TEST SPLIT
# ============================================================

set.seed(42)
split_index <- createDataPartition(loan_data$Loan_Status, p = 0.80, list = FALSE)
train_set   <- loan_data[split_index, ]
test_set    <- loan_data[-split_index, ]

cat("\nTraining set size:", nrow(train_set))
cat("\nTest set size:", nrow(test_set), "\n")


# ============================================================
# STEP 6: MODEL TRAINING & EVALUATION
# ============================================================

# Cross-validation control
ctrl <- trainControl(method = "cv", number = 5)

results <- list()

# ---- 6a. Logistic Regression ----
cat("\n--- Training Logistic Regression ---\n")
set.seed(42)
lr_model <- train(Loan_Status ~ ., data = train_set,
                  method = "glm", family = "binomial",
                  trControl = ctrl)

lr_pred    <- predict(lr_model, newdata = test_set)
lr_cm      <- confusionMatrix(lr_pred, test_set$Loan_Status)
lr_acc     <- lr_cm$overall["Accuracy"]
results[["Logistic Regression"]] <- round(lr_acc * 100, 2)

cat("Logistic Regression Accuracy:", round(lr_acc * 100, 2), "%\n")
cat("\nConfusion Matrix - Logistic Regression:\n")
print(lr_cm$table)


# ---- 6b. Decision Tree ----
cat("\n--- Training Decision Tree ---\n")
set.seed(42)
dt_model <- train(Loan_Status ~ ., data = train_set,
                  method = "rpart", trControl = ctrl)

dt_pred <- predict(dt_model, newdata = test_set)
dt_cm   <- confusionMatrix(dt_pred, test_set$Loan_Status)
dt_acc  <- dt_cm$overall["Accuracy"]
results[["Decision Tree"]] <- round(dt_acc * 100, 2)

cat("Decision Tree Accuracy:", round(dt_acc * 100, 2), "%\n")
cat("\nConfusion Matrix - Decision Tree:\n")
print(dt_cm$table)

# Plot Decision Tree
rpart.plot(dt_model$finalModel, type = 4, extra = 101,
           main = "Decision Tree - Loan Approval")


# ---- 6c. Random Forest ----
cat("\n--- Training Random Forest ---\n")
set.seed(42)
rf_model <- train(Loan_Status ~ ., data = train_set,
                  method = "rf", trControl = ctrl,
                  ntree = 100)

rf_pred <- predict(rf_model, newdata = test_set)
rf_cm   <- confusionMatrix(rf_pred, test_set$Loan_Status)
rf_acc  <- rf_cm$overall["Accuracy"]
results[["Random Forest"]] <- round(rf_acc * 100, 2)

cat("Random Forest Accuracy:", round(rf_acc * 100, 2), "%\n")
cat("\nConfusion Matrix - Random Forest:\n")
print(rf_cm$table)

# Feature Importance
varImpPlot(rf_model$finalModel,
           main = "Random Forest - Feature Importance",
           col = "steelblue", pch = 19)


# ---- 6d. Support Vector Machine (SVM) ----
cat("\n--- Training SVM ---\n")
set.seed(42)
svm_model <- train(Loan_Status ~ ., data = train_set,
                   method = "svmRadial", trControl = ctrl,
                   preProcess = c("center", "scale"))

svm_pred <- predict(svm_model, newdata = test_set)
svm_cm   <- confusionMatrix(svm_pred, test_set$Loan_Status)
svm_acc  <- svm_cm$overall["Accuracy"]
results[["SVM"]] <- round(svm_acc * 100, 2)

cat("SVM Accuracy:", round(svm_acc * 100, 2), "%\n")
cat("\nConfusion Matrix - SVM:\n")
print(svm_cm$table)


# ============================================================
# STEP 7: MODEL COMPARISON
# ============================================================

cat("\n========================================\n")
cat("       MODEL ACCURACY COMPARISON\n")
cat("========================================\n")
results_df <- data.frame(
  Model    = names(results),
  Accuracy = unlist(results)
)
results_df <- results_df[order(-results_df$Accuracy), ]
print(results_df)

# Plot Accuracy Comparison
ggplot(results_df, aes(x = reorder(Model, Accuracy), y = Accuracy, fill = Model)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = paste0(Accuracy, "%")), hjust = -0.1, size = 4) +
  coord_flip() +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Model Accuracy Comparison",
       x = "Model", y = "Accuracy (%)") +
  ylim(0, 100) +
  theme_minimal() +
  theme(legend.position = "none")


# ============================================================
# STEP 8: BEST MODEL PREDICTION
# ============================================================

best_model_name <- results_df$Model[1]
cat("\nBest Model:", best_model_name, "with Accuracy:", results_df$Accuracy[1], "%\n")

best_model <- switch(best_model_name,
  "Logistic Regression" = lr_model,
  "Decision Tree"       = dt_model,
  "Random Forest"       = rf_model,
  "SVM"                 = svm_model
)

cat("\n--- Final Predictions on Test Set using Best Model ---\n")
final_preds <- predict(best_model, newdata = test_set)
final_cm    <- confusionMatrix(final_preds, test_set$Loan_Status)
print(final_cm)

# Confusion Matrix Heatmap
cm_table <- as.data.frame(final_cm$table)
ggplot(cm_table, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), size = 6, fontface = "bold") +
  scale_fill_gradient(low = "#e8f5e9", high = "#388E3C") +
  labs(title = paste("Confusion Matrix —", best_model_name),
       x = "Actual", y = "Predicted") +
  theme_minimal()

cat("\n============================================================\n")
cat("  PROJECT COMPLETE! Best model:", best_model_name, "\n")
cat("============================================================\n")

# Save the best model for the Shiny application
saveRDS(best_model, "loan_model.rds")
cat("Best model successfully saved to 'loan_model.rds'\n")