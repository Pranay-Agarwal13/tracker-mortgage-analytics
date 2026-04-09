# Loan Approval Prediction — R Project

## Overview
End-to-end machine learning project in R that predicts whether a loan application will be **approved (Y)** or **rejected (N)** using applicant demographic and financial data.

---

## Project Structure

```
loan_approval_prediction.R   ← Single self-contained script
README.md                    ← This file
```

### Outputs Generated (after running the script)
| File | Description |
|------|-------------|
| `eda_plots.png` | 6-panel EDA dashboard |
| `model_performance.png` | Accuracy, F1, grouped metrics, confusion matrix |
| `feature_importance.png` | Random Forest feature rankings |
| `decision_tree.png` | Visual decision tree diagram |

---

## How to Run

### Requirements
```r
install.packages(c(
  "ggplot2", "dplyr", "tidyr", "caret",
  "rpart", "rpart.plot", "randomForest",
  "e1071", "corrplot", "gridExtra",
  "scales", "ggcorrplot", "pROC"
))
```

### Execute
```r
source("loan_approval_prediction.R")
```
or open in RStudio and click **Source**.

---

## Dataset Features

| Feature | Type | Description |
|---------|------|-------------|
| Gender | Categorical | Male / Female |
| Married | Categorical | Yes / No |
| Dependents | Categorical | 0 / 1 / 2 / 3+ |
| Education | Categorical | Graduate / Not Graduate |
| Self_Employed | Categorical | Yes / No |
| ApplicantIncome | Numeric | Monthly income of applicant |
| CoapplicantIncome | Numeric | Monthly income of co-applicant |
| LoanAmount | Numeric | Requested loan amount (₹K) |
| Loan_Amount_Term | Numeric | Term in months |
| Credit_History | Binary | 1 = good history, 0 = none |
| Property_Area | Categorical | Urban / Semiurban / Rural |
| **Loan_Status** | **Target** | **Y = Approved, N = Rejected** |

---

## Pipeline Summary

```
Raw Data
  │
  ├─ EDA & Visualization
  │
  ├─ Preprocessing
  │    ├─ Impute missing values (mode / median)
  │    └─ Feature Engineering
  │         ├─ Total_Income = Applicant + Coapplicant
  │         ├─ EMI = LoanAmount / Term
  │         ├─ Balance_Income = Income − (EMI × 1000)
  │         ├─ Income_per_LoanAmount ratio
  │         └─ Log transforms (skewed features)
  │
  ├─ Train / Test Split (80 / 20, stratified)
  │
  ├─ Models (5-Fold Cross Validation)
  │    ├─ Logistic Regression
  │    ├─ Decision Tree  (tuned cp)
  │    ├─ Random Forest  (tuned mtry)
  │    └─ SVM — RBF Kernel (tuned C, sigma)
  │
  └─ Evaluation
       ├─ Accuracy, Kappa, Precision, Recall, F1
       ├─ Confusion Matrix
       └─ Best model used for new predictions
```

---

## Evaluation Metrics Explained

| Metric | Meaning |
|--------|---------|
| **Accuracy** | Overall correct predictions / total |
| **Kappa** | Agreement beyond chance |
| **Precision** | Of predicted approvals, how many were correct |
| **Recall** | Of actual approvals, how many were caught |
| **F1 Score** | Harmonic mean of Precision & Recall |

---

## Key Design Choices

- **Stratified split** — ensures class balance in train/test
- **5-fold CV** — reduces overfitting during tuning
- **Log transforms** — handles right-skewed income/loan distributions
- **Feature engineering** — EMI and balance income are strong predictors
- **Metric: ROC AUC** — used during CV to handle class imbalance

---

## Extending the Project

```r
# Use your own CSV instead of synthetic data:
loan_data <- read.csv("your_loan_data.csv")

# Popular real dataset (Kaggle):
# https://www.kaggle.com/datasets/altruistdelhite04/loan-prediction-problem-dataset
```