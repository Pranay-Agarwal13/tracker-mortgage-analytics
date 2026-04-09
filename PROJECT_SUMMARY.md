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

## 🔄 System Workflow (How It Works)

To fully understand the project for your presentation, here is the exact chronological execution flow of the system:

1. **Client Interaction**: 
   A user accesses the server via their web browser and lands on the DASHBOARD. They transition to the **OFFERS** tab and fill out the interactive application details (e.g., ticking 'Graduate', sliding Income to ₹80,000, Requesting ₹500,000, and marking Credit History as 'Good').
   
2. **Data Marshaling**: 
   Upon pressing the green `EVALUATE APPROVAL` button, the R Shiny framework (`app.R`) instantly wraps these individual demographic variables into an isolated, temporary R Dataframe structure identical to `train.csv`.
   
3. **Internal Normalization**: 
   Just like during the initial training of the machine learning model, the `app.R` script immediately applies a `log(X + 1)` mathematical transform to the user's raw *Applicant Income*, *Coapplicant Income*, and *Loan Amount* to normalize the scales and compress extreme wealth outliers.

4. **Live Algorithmic Inference**: 
   The formatted dataframe is passed explicitly into `predict(model, newdata = d, type = "prob")`. The active Logistic Regression model (`loan_model.rds`) multiplies these inputs by its optimized historical feature weights, generating an exact floating-point probability score (e.g., `0.8524`).

5. **Interface Mutation (The Output)**: 
   The server intercepts the calculated probability output. If the algorithm determines the metric exceeds the risk threshold (> 50% Approval), it triggers a massive HTML/CSS state update:
   * The probability gauge renders green and displays `85.24%`.
   * The Decision Panel dynamically updates to display an **"Approved"** verdict.
   * `Leaflet` kicks in, cross-referencing your chosen city on the interactive map to offer premium interest rates based on your verified low-risk status.
   * Moving to the **LOANS** tab, the math engine actively compounds this new principal against the floating interest rate into an Amortization Table, instantly calculating your Equated Monthly Installment (EMI).

## 🚀 How to Run the Project
To launch the beautiful graphical user interface:
1. Open up your R console or VS Code Terminal.
2. Ensure your working directory is set to the project folder (`d:\CODING\DS Lab\loan_approval_project`).
3. Run the following command:
```R
shiny::runApp('app.R')
```
