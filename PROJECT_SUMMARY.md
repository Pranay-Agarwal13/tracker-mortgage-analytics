# Tracker Mortgage Analytics Engine
**Loan Approval Prediction System**

This file contains a complete overview of the Data Science project architectures, tech stacks, and capabilities implemented in this directory. It is designed to help you prepare for presentations or perfectly understand the backend logic of the system.

## 🎯 Project Overview
The **Tracker Mortgage Analytics Engine** is a full-stack Data Science application built entirely in R. It simulates a modern, enterprise-level Fintech banking interface. The system leverages a trained Machine Learning model to evaluate a user's financial profile and instantly calculate an exact "Approval Probability," returning a computed decision regarding their loan application.

## ⚙️ Tech Stack & Dependencies
This project is powered by a robust R ecosystem.
- **Language Framework**: R (v4.5+)
- **Frontend Architecture**: R Shiny (`shiny`)
- **UI/UX Design framework**: `bslib` & `shinyWidgets` (Used to create the incredible Glassmorphic Tracker Mortgage design and dynamic nav-routing)
- **Geospatial Analytics**: `leaflet` (Powers the interactive "Select City" mapping system to dynamically fetch regional interest rates)
- **Machine Learning**: `caret` and `stats`
- **Data Manipulation**: `dplyr`

## 📂 Architecture & Files

### 1. `loan.R` (The Machine Learning Engine)
This is the core "Data Scientist" script of the project. It runs independently from the website to train the intelligence of the platform.
*   **Preprocessing**: Imports `train.csv` and handles missing data via imputation (e.g., using mean/mode replacement for blank fields).
*   **Feature Engineering**: Applies mathematical `log()` transformations to `ApplicantIncome` and `LoanAmount` to prevent extreme wealth outliers from destroying the accuracy of the predictions.
*   **Model Training**: The script uses `caret` to perform an 80/20 train-test split. It extensively evaluated multiple massive classification algorithms:
    *   Decision Trees
    *   Random Forest
    *   Support Vector Machines (SVM)
    *   Logistic Regression
*   **Serialization**: **Logistic Regression** proved out, so the script permanently exports its intelligence to a file called `loan_model.rds` using `saveRDS()`.

### 2. `app.R` (The Frontend Shiny App)
This is the massive interface that the user actually sees. It is built utilizing modern CSS architectures simulating a $1M Fintech company.
*   **DASHBOARD Tab**: An ultra-clean landing page displaying 4 system-wide metric cards (e.g., 68.2% System Approval, Total Trackers). It serves as the clean presentation introduction layer.
*   **OFFERS Tab (The Heart of the Project)**: 
    *   Acts as the form where clients input their financial parameters (Income, Dependents, Credit History).
    *   **Live Inference**: When "EVALUATE APPROVAL" is clicked, Shiny catches the inputs, structures them identically to the `train.csv` formats, and forces `loan_model.rds` to run a `predict()` sequence. 
    *   The model returns a probability out of 100%, firing a dynamic progress bar and a final Approved/Rejected Decision Verdict.
    *   **Map Integration**: Powered by `leaflet`, it contains a click-to-load map of India where selecting cities (Delhi, Mumbai, Jaipur) dynamically injects their regional, floating interest rates into your approved mortgage offers.
*   **LOANS Tab**: Implements heavy active agreement modeling. It contains the raw mathematical compounding formulas required to calculate your Equated Monthly Installment (EMI) based on the Principal, Custom Rate, and Tenure. It actively renders the first 5 months of an Amortization Table.
*   **TRANSACTIONS Tab**: A dummy ledger showing pending simulated deductions to make the application feel like a fully integrated bank sandbox.

### 3. `loan_model.rds`
The "Brain". This file contains the serialized, saved Logistic Regression machine learning matrices. `app.R` loads this immediately on launch into active memory to perform live probability generations.

## 🚀 How to Run the Project
To launch the beautiful graphical user interface:
1. Open up your R console or VS Code Terminal.
2. Ensure your working directory is set to the project folder (`d:\CODING\DS Lab\loan_approval_project`).
3. Run the following command:
```R
shiny::runApp('app.R')
```
