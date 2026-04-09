library(shiny)
library(bslib)
library(dplyr)
library(leaflet)
library(shinyWidgets)
library(plotly)

# Load the trained model
model <- readRDS("loan_model.rds")


# Custom CSS
custom_css <- "
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');

body {
  font-family: 'Inter', sans-serif;
  background: linear-gradient(135deg, #fcece9 0%, #e8f9f7 40%, #eefbf4 70%, #f9eef6 100%);
  background-attachment: fixed;
  color: #2b2b2b;
  min-height: 100vh;
}

/* Navbar Mimic */
.tracker-navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 40px;
}
.tracker-logo {
  font-weight: 700;
  font-size: 22px;
  color: #1a1a1a;
  display: flex;
  align-items: center;
}
.tracker-logo span {
  color: #2eb872; /* Green accent */
  font-size: 26px;
  margin-right: 8px;
}
.tracker-nav-links {
  display: flex;
  gap: 30px;
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.tracker-nav-links a {
  color: #8fa0af;
  text-decoration: none;
  cursor: pointer;
}
.tracker-nav-links a.active, .tracker-nav-links a:hover {
  color: #2eb872;
  text-decoration: none;
}

/* Glassmorphic Cards */
.glass-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 30px;
  border: 1px solid rgba(255, 255, 255, 0.9);
  box-shadow: 0 10px 40px rgba(0,0,0,0.03);
  margin-bottom: 20px;
}

/* Typography Customizations */
.lbl-heading {
  font-size: 14px;
  font-weight: 600;
  color: #1a1a1a;
  margin-bottom: 4px;
}
.val-large {
  font-size: 32px;
  font-weight: 700;
  color: #fa5c55; /* Default red */
}
.val-large.green { color: #2eb872; }

.sub-text {
  font-size: 12px;
  color: #8c9096;
}

/* Inputs styling */
.form-control, .selectize-input {
  border-radius: 12px !important;
  background-color: transparent !important;
  border: none !important;
  border-bottom: 1.5px solid #dcdcdc !important;
  box-shadow: none !important;
  padding: 8px 0px !important;
  font-weight: 600;
  color: #1a1a1a;
}
.form-control:focus, .selectize-input.focus {
  border-bottom: 2px solid #2eb872 !important;
}

.btn-predict {
  background-color: #2eb872 !important;
  color: white !important;
  border-radius: 30px;
  font-weight: 600;
  padding: 12px 0;
  width: 100%;
  border: none;
  font-size: 16px;
  margin-top: 15px;
  transition: transform 0.2s, box-shadow 0.2s;
  box-shadow: 0 5px 15px rgba(46, 184, 114, 0.3);
}
.btn-predict:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(46, 184, 114, 0.4);
}

/* Dashboards Metrics */
.stat-value { font-size: 28px; font-weight: 800; color: #1a1a1a; }
.stat-label { font-size: 12px; color: #8fa0af; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 5px; }

/* Offer Cards */
.offer-card {
  min-width: 220px;
  background: white;
  border-radius: 20px;
  padding: 20px;
  border: 1px solid #eaeaea;
  box-shadow: 0 5px 15px rgba(0,0,0,0.02);
  display: inline-block;
}
.offer-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 700;
  background: rgba(46,184,114,0.1);
  color: #2eb872;
  margin-bottom: 10px;
}

/* Map Wrapper */
.map-wrapper {
  position: relative;
  border-radius: 24px;
  overflow: hidden;
  height: 400px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.05);
}
.floating-glass {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 320px;
  background: rgba(255, 255, 255, 0.75);
  backdrop-filter: blur(15px);
  -webkit-backdrop-filter: blur(15px);
  border-radius: 20px;
  padding: 20px;
  z-index: 1000;
  border: 1px solid rgba(255,255,255,0.9);
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
}

/* Beautiful Tables */
.table-clean { width: 100%; border-collapse: collapse; }
.table-clean th, .table-clean td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; text-align: left; font-size: 14px; }
.table-clean th { color: #8fa0af; font-weight: 600; font-size: 12px; text-transform: uppercase; }
"

ui <- fluidPage(
  tags$head(
    tags$style(HTML(custom_css)),
    # Include FontAwesome for icons natively just in case
    tags$link(rel="stylesheet", href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css")
  ),
  
  # Custom Navbar Engine (Dynamic)
  div(class = "tracker-navbar",
      div(class = "tracker-logo", HTML("<span>\u2951</span> Tracker Mortgage")),
      div(class = "tracker-nav-links",
          uiOutput("nav_dynamic_links", inline = TRUE)
      ),
      div(style = "display:flex; gap:15px; align-items:center;",
          tags$i(class = "fa fa-bell", style="color:#8fa0af;"),
          tags$i(class = "fa fa-user-circle", style="color:#8fa0af; font-size:20px;")
      )
  ),
  
  # Navset Router
  navset_hidden(
    id = "main_tabs",
    
    # ------------------ TAB 1: DASHBOARD ------------------
    nav_panel(title = "DASHBOARD", value = "DASHBOARD",
      fluidRow(
        style = "padding: 0 40px;",
        column(12, 
          # Top row: 4 Metric Cards
          fluidRow(
            column(3, div(class="glass-card text-center", style="padding:25px;", div(class="stat-value", "12,450"), div(class="stat-label", "Total Trackers"))),
            column(3, div(class="glass-card text-center", style="padding:25px;", div(class="stat-value", "\u20B94.5L"), div(class="stat-label", "Avg Loan Size"))),
            column(3, div(class="glass-card text-center", style="padding:25px;", div(class="stat-value", style="color:#2eb872;", "68.2%"), div(class="stat-label", "System Approval"))),
            column(3, div(class="glass-card text-center", style="padding:25px;", div(class="stat-value", "8.50%"), div(class="stat-label", "Base Rate p.a.")))
          ),
          
          # Clean Informational View
          div(class="glass-card", style="min-height: 400px; display:flex; flex-direction:column; justify-content:center; align-items:center; text-align:center;",
              div(style="font-size:48px; color:#2eb872; margin-bottom:20px;", HTML("\u2951")),
              h2("Tracker Mortgage Analytics Engine", style="font-weight:800; color:#1a1a1a; margin-bottom:15px;"),
              p(style="color:#666; font-size:16px; max-width:600px;", "Welcome to the central command center. Our proprietary Logistic Regression algorithms compute real-time structural risk analysis against incoming loan payloads."),
              tags$br(),
              actionButton("go_OFFERS_from_dash", "EVALUATE A NEW LOAN", class="btn-predict", style="width: 250px; margin-top:20px;")
          )
        )
      )
    ),
    
    # ------------------ TAB 2: OFFERS ------------------
    nav_panel(title = "OFFERS", value = "OFFERS",
      fluidRow(
        style = "padding: 0 40px;",
        
        # LEFT PANEL
        column(4,
          div(class = "glass-card", style = "min-height: 800px;",
              div(style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 25px;",
                   h4("Application Input", style="font-weight:700;"),
                   div(style="font-size:12px; color:#999; display:flex; align-items:center; gap:5px;",
                       "Autofill", tags$i(class="fa fa-toggle-on", style="color:#2eb872; font-size:18px;")
                   )
              ),
              
              div(style="margin-bottom:30px;",
                  div(class="lbl-heading", "Your Requested Amount"),
                  uiOutput("requested_amt_ui"),
                  div(class="sub-text", style="color:#fa5c55; margin-top:5px; background:rgba(250,92,85,0.1); padding:8px 12px; border-radius:8px; border:1px solid rgba(250,92,85,0.2);",
                      "\u26A0\uFE0F Required documents are scheduled for review."
                  )
              ),
              
              fluidRow(
                column(6, pickerInput("gender", "Gender", choices = c("Male", "Female"))),
                column(6, pickerInput("married", "Married", choices = c("No", "Yes")))
              ),
              fluidRow(
                column(6, pickerInput("dependents", "Dependents", choices = c("0", "1", "2", "3+"))),
                column(6, pickerInput("education", "Education", choices = c("Graduate", "Not Graduate")))
              ),
              fluidRow(
                column(6, pickerInput("self_employed", "Self Employed", choices = c("No", "Yes"))),
                column(6, pickerInput("property_area", "Property Area", choices = c("Urban", "Semiurban", "Rural")))
              ),
              
              tags$hr(style="border-top: dashed 1px #cbd0d4; margin: 20px 0;"),
              
              fluidRow(
                column(6, numericInput("applicant_income", "Applicant Income (\u20B9)", value = 50000, step=1000)),
                column(6, numericInput("coapplicant_income", "Coapp Income (\u20B9)", value = 0, step=1000))
              ),
              fluidRow(
                column(6, numericInput("loan_amount", "Loan Amount (\u20B9)", value = 15000, step=100)),
                column(6, numericInput("loan_amount_term", "Term (Months)", value = 360, step=12))
              ),
              
              pickerInput("credit_history", "Credit History Profile", 
                          choices = c("Good (Acceptable)" = "1", "Bad (Not Acceptable)" = "0"), width="100%"),
              
              actionButton("predict_btn", "EVALUATE APPROVAL", class="btn-predict")
          )
        ),
        
        # RIGHT PANELS
        column(8,
               div(class = "glass-card", style="display:flex; justify-content:space-between; align-items:center; padding: 25px 40px;",
                   div(
                     div(class="lbl-heading", style="color:#666;", "Your estimated Approval Probability is"),
                     uiOutput("prob_top_ui")
                   ),
                   div(style="flex-grow:1; max-width:400px;", uiOutput("prob_progress_bar"))
               ),
               
               # Sponsored Match Offers Row
               uiOutput("match_offers_ui"),
               
               div(class = "map-wrapper",
                   leafletOutput("india_map", width = "100%", height = "100%"),
                   div(class = "floating-glass",
                       div(style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 15px;",
                           div(style="font-weight:700; font-size:18px;", "Decision Panel"),
                       ),
                       uiOutput("decision_verdict"),
                       tags$hr(style="margin:15px 0; border: none; border-bottom: 1px solid rgba(0,0,0,0.1);"),
                       div(style="font-size:13px; color:#555; line-height:1.6;", uiOutput("decision_summary")),
                       div(style="margin-top:15px; font-size:11px; color:#999; text-align:center;", "Decision modeled via Logistic Regression")
                   )
               )
        )
      )
    ),
    
    # ------------------ TAB 3: LOANS ------------------
    nav_panel(title = "LOANS", value = "LOANS",
      fluidRow(
        style = "padding: 0 40px;",
        column(3,
          div(class="glass-card",
              h4("Amortization Controls", style="font-weight:700; margin-bottom:20px; font-size:16px;"),
              numericInput("loans_calc_amount", "Principal (\u20B9)", value = 15000, step=1000),
              numericInput("loans_calc_rate", "Interest Rate (%)", value = 8.5, step=0.1),
              numericInput("loans_calc_term", "Tenure (Months)", value = 360, step=12),
              actionButton("sync_loan_btn", "Sync from Model Output", icon=icon("refresh"), class="btn btn-outline-secondary w-100", style="margin-top:15px; border-radius:15px;")
          )
        ),
        column(9, 
          div(class="glass-card",
              h3("Active Agreement Modeling", style="font-weight:700; color:#1a1a1a; margin-bottom:30px;"),
              fluidRow(
                column(4, 
                   div(class="lbl-heading", "Calculated Installment (EMI)"),
                   uiOutput("calculated_emi_ui"),
                   uiOutput("emi_rate_sub_text")
                ),
                column(8,
                   div(class="lbl-heading", "Repayment Progress Timeline"),
                   # Progress bar visualization (Dummy 15% state to represent an active loan format)
                   div(style="width:100%; height:12px; background:rgba(0,0,0,0.05); border-radius:6px; overflow:hidden; margin-top:8px; margin-bottom:5px;",
                       div(style="width:15%; height:100%; background:#2eb872;")
                   ),
                   div(style="display:flex; justify-content:space-between;", 
                       div(class="sub-text", "15% Principal Settled"),
                       uiOutput("remaining_time_ui")
                   )
                )
              ),
              tags$hr(style="margin:30px 0; max-width:100%; border-top: 1px solid #eee;"),
              h5("Complete Amortization Schedule", style="font-weight:700; margin-bottom:20px;"),
              tableOutput("amortization_table")
          )
        )
      )
    ),
    
    # ------------------ TAB 4: TRANSACTIONS ------------------
    nav_panel(title = "TRANSACTIONS", value = "TRANSACTIONS",
      fluidRow(
        style = "padding: 0 40px;",
        column(12, 
          div(class="glass-card", style="background: rgba(250,92,85,0.05); border: 1px solid rgba(250,92,85,0.2); padding: 25px;",
              div(style="display:flex; align-items:center; gap: 20px;",
                  tags$i(class="fa fa-exclamation-triangle", style="color:#fa5c55; font-size:32px;"),
                  div(
                     div(style="font-weight:700; color:#fa5c55; font-size: 18px;", "Upcoming Payment Due!"),
                     uiOutput("emi_reminder_text")
                  )
              )
          ),
          div(class="glass-card", style="margin-top:20px;",
              div(style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;",
                  h4("Recent Transaction Log", style="font-weight:700; margin:0;"),
                  tags$a("Download PDF", class="btn btn-sm btn-outline-secondary", style="border-radius:15px;")
              ),
              tableOutput("transaction_history")
          )
        )
      )
    )
    
  ) # End navset
)

server <- function(input, output, session) {
  
  # Base format helper
  format_inr <- function(x) { paste0("\u20B9", formatC(x, format="f", digits=0, big.mark=",")) }
  
  # --- NAV ROUTING ENGINE ---
  rv <- reactiveValues(active_tab = "DASHBOARD")
  
  observeEvent(input$go_DASHBOARD, { rv$active_tab <- "DASHBOARD"; nav_select("main_tabs", "DASHBOARD") })
  observeEvent(input$go_OFFERS, { rv$active_tab <- "OFFERS"; nav_select("main_tabs", "OFFERS") })
  observeEvent(input$go_LOANS, { rv$active_tab <- "LOANS"; nav_select("main_tabs", "LOANS") })
  observeEvent(input$go_TRANSACTIONS, { rv$active_tab <- "TRANSACTIONS"; nav_select("main_tabs", "TRANSACTIONS") })

  output$nav_dynamic_links <- renderUI({
    tags$div(style="display:flex; gap:30px;",
      actionLink("go_DASHBOARD", "DASHBOARD", class = ifelse(rv$active_tab == "DASHBOARD", "active", "")),
      actionLink("go_OFFERS", "OFFERS", class = ifelse(rv$active_tab == "OFFERS", "active", "")),
      actionLink("go_LOANS", "LOANS", class = ifelse(rv$active_tab == "LOANS", "active", "")),
      actionLink("go_TRANSACTIONS", "TRANSACTIONS", class = ifelse(rv$active_tab == "TRANSACTIONS", "active", ""))
    )
  })
  
  observeEvent(input$go_OFFERS_from_dash, { rv$active_tab <- "OFFERS"; nav_select("main_tabs", "OFFERS") })
  
  output$requested_amt_ui <- renderUI({ div(class="val-large", format_inr(input$loan_amount)) })
  
  
  # --- MATHEMATICAL EMI & LOAN COMPUTATIONS ---
  
  # Observer to sync Dashboard Model Inputs into the Loan calculator manually
  observeEvent(input$sync_loan_btn, {
    updateNumericInput(session, "loans_calc_amount", value = input$loan_amount)
    updateNumericInput(session, "loans_calc_term", value = input$loan_amount_term)
  })
  
  emi_calc <- reactive({
    P <- as.numeric(input$loans_calc_amount)
    n <- as.numeric(input$loans_calc_term)  # Treated as total months
    r <- (as.numeric(input$loans_calc_rate) / 100) / 12  # Dynamic annual rate configured to monthly chunk
    
    # Avoid division by zero if inputs are 0
    if(is.na(P) || is.na(n) || P <= 0 || n <= 0 || is.na(r) || r < 0) return(0)
    
    if (r == 0) return(round(P / n, 0))
    emi <- (P * r * (1 + r)^n) / ((1 + r)^n - 1)
    return(round(emi, 0))
  })
  
  output$calculated_emi_ui <- renderUI({
    div(class="val-large", style="color:#2eb872;", format_inr(emi_calc()))
  })
  output$emi_rate_sub_text <- renderUI({
    div(class="sub-text", paste0("Based on ", input$loans_calc_rate, "% p.a. custom rate"))
  })
  output$remaining_time_ui <- renderUI({
    div(class="sub-text", paste0(input$loans_calc_term, " Months Total Schedule"))
  })
  
  output$amortization_table <- renderTable({
    # Build complete amortization table
    emi <- emi_calc()
    P <- as.numeric(input$loans_calc_amount)
    r <- (as.numeric(input$loans_calc_rate) / 100) / 12
    
    if(P <= 0 || emi <= 0) return(NULL)
    
    out <- data.frame(Period=integer(), Payment=character(), Principal=character(), Interest=character(), Balance=character())
    balance <- P
    
    # Cap maximum iterations to prevent Shiny app crashing via memory overload
    calc_limit <- min(600, as.numeric(input$loans_calc_term))
    
    for(i in 1:calc_limit) {
      interest_pmt <- balance * r
      principal_pmt <- emi - interest_pmt
      balance <- balance - principal_pmt
      out[i,] <- c(
        paste("Month", i),
        format_inr(emi),
        format_inr(principal_pmt),
        format_inr(interest_pmt),
        format_inr(max(0, balance))
      )
    }
    colnames(out) <- c("Period", "EMI Payment", "Principal", "Interest", "Remaining Balance")
    out
  }, class="table-clean", width="100%", rownames = FALSE)
  
  
  # --- TRANSACTIONS LOGIC ---
  output$emi_reminder_text <- renderUI({
    div(style="color:#666; font-size:13px; margin-top:2px;", 
        HTML(paste0("Your next scheduled auto-debit of <b>", format_inr(emi_calc()), "</b> is arriving on <b>Apr 15, 2026</b>.")))
  })
  output$transaction_history <- renderTable({
    emi <- format_inr(emi_calc())
    data.frame(
      Date = c("Mar 15, 2026", "Feb 15, 2026", "Jan 15, 2026", "Dec 15, 2025"),
      Description = rep("Automated Mortgage Deduction", 4),
      Amount = rep(emi, 4),
      Status = rep("✅ Settled", 4)
    )
  }, class="table-clean", width="100%", rownames=FALSE)

  
  # --- OFFERS & PREDICTION LOGIC ---
  pred_res <- eventReactive(input$predict_btn, {
    # Construct matching features
    d <- data.frame(
      Gender = factor(input$gender, levels = c("", "Female", "Male")),
      Married = factor(input$married, levels = c("", "No", "Yes")),
      Dependents = factor(input$dependents, levels = c("", "0", "1", "2", "3+")),
      Education = factor(input$education, levels = c("Graduate", "Not Graduate")),
      Self_Employed = factor(input$self_employed, levels = c("", "No", "Yes")),
      ApplicantIncome = as.integer(input$applicant_income),
      CoapplicantIncome = as.numeric(input$coapplicant_income),
      LoanAmount = as.numeric(input$loan_amount) / 1000,
      Loan_Amount_Term = as.numeric(input$loan_amount_term),
      Credit_History = factor(input$credit_history, levels = c("0", "1")),
      Property_Area = factor(input$property_area, levels = c("Rural", "Semiurban", "Urban"))
    )
    
    # Transforms
    d$LoanAmount_log <- log(d$LoanAmount + 1)
    d$ApplicantIncome_log <- log(d$ApplicantIncome + 1)
    d$CoapplicantIncome_log <- log(d$CoapplicantIncome + 1)
    
    pred_class <- predict(model, newdata = d)
    prob <- predict(model, newdata = d, type = "prob")[,"Y"]
    
    list(status = as.character(pred_class), prob = prob, data = d)
  }, ignoreNULL = FALSE)
  
  output$prob_top_ui <- renderUI({
    res <- pred_res()
    prob_pct <- round(res$prob * 100, 2)
    color_class <- ifelse(res$status == "Y", "green", "")
    div(style="display:flex; gap:30px; margin-top:10px;",
        div(
          div(style="font-size:12px; color:#999; text-transform: uppercase; font-weight: 600;", "Likelihood"),
          div(class=paste("val-large", color_class), style="font-size:28px;", paste0(prob_pct, "%"))
        )
    )
  })
  
  output$prob_progress_bar <- renderUI({
    res <- pred_res()
    pct <- res$prob * 100
    color <- ifelse(res$status == "Y", "#2eb872", "#fa5c55")
    div(style="width:100%; height:8px; background:rgba(0,0,0,0.05); border-radius:4px; overflow:hidden; margin-top:20px;",
        div(style=paste0("width:", pct, "%; height:100%; background:", color, "; transition: width 0.5s;"))
    )
  })
  
  # --- INTERACTIVE MAP & REGIONAL OFFERS LOGIC ---
  cities_data <- data.frame(
    id = c("Mumbai", "Delhi", "Bangalore", "Kolkata", "Chennai", "Hyderabad", "Jaipur"),
    lat = c(19.0760, 28.7041, 12.9716, 22.5726, 13.0827, 17.3850, 26.9124),
    lng = c(72.8777, 77.1025, 77.5946, 88.3639, 80.2707, 78.4867, 75.7873),
    base_rate = c(8.5, 8.2, 8.8, 7.9, 8.1, 8.0, 8.3)
  )
  
  selected_city <- reactiveVal("Mumbai") # Default Selection
  
  observeEvent(input$india_map_marker_click, {
    click <- input$india_map_marker_click
    if(!is.null(click$id)) {
      selected_city(click$id)
    }
  })
  
  output$match_offers_ui <- renderUI({
    res <- pred_res()
    prob_pct <- round(res$prob * 100, 1)
    
    city <- selected_city()
    rate_adjust <- cities_data$base_rate[cities_data$id == city]
    
    div(style="display:flex; gap:20px; margin-bottom:20px; overflow-x: auto; padding-bottom:10px;",
        div(class="offer-card",
            div(class="offer-badge", paste0(prob_pct, "% Match Rate")),
            h5(paste(city, "Premium Fixed"), style="font-weight:700; font-size:15px; margin:0; color:#1a1a1a;"),
            div(style="font-size:12px; color:#777; margin-top:5px;", paste0(rate_adjust - 1.0, "% p.a \u2022 0 Processing Fees")),
            tags$button("Select Offer", class="btn btn-sm btn-outline-success", style="margin-top:15px; border-radius:15px; width:100%;")
        ),
        div(class="offer-card",
            div(class="offer-badge", style=ifelse(res$prob<0.5,"background:rgba(250,92,85,0.1); color:#fa5c55;",""), paste0(prob_pct, "% Match Rate")),
            h5(paste(city, "Standard Flexi"), style="font-weight:700; font-size:15px; margin:0; color:#1a1a1a;"),
            div(style="font-size:12px; color:#777; margin-top:5px;", paste0(rate_adjust, "% p.a \u2022 Floating Margin")),
            tags$button("Select Offer", class="btn btn-sm btn-outline-success", style="margin-top:15px; border-radius:15px; width:100%;")
        )
    )
  })
  
  output$decision_verdict <- renderUI({
    res <- pred_res()
    if(res$status == "Y"){
      div(
        h3(style="color:#2eb872; font-weight:700; margin:0 0 5px 0; font-size:24px;", "Approved"),
        div(style="color:#777; font-size:12px;", "Great news! Your application meets the risk threshold criteria.")
      )
    } else {
      div(
        h3(style="color:#fa5c55; font-weight:700; margin:0 0 5px 0; font-size:24px;", "Rejected"),
        div(style="color:#777; font-size:12px;", "Unfortunately, this request falls outside our risk allowance.")
      )
    }
  })
  
  output$decision_summary <- renderUI({
    HTML(paste0(
      "<div style='display:flex; justify-content:space-between; margin-bottom:8px;'><span>Income Base:</span> <b>", format_inr(input$applicant_income), "</b></div>",
      "<div style='display:flex; justify-content:space-between; margin-bottom:8px;'><span>Co-Applicant:</span> <b>", format_inr(input$coapplicant_income), "</b></div>",
      "<div style='display:flex; justify-content:space-between; margin-bottom:8px;'><span>Property Area:</span> <b>", input$property_area, "</b></div>",
      "<div style='display:flex; justify-content:space-between; margin-bottom:0;'><span>Credit Rating:</span> <b>", ifelse(input$credit_history=="1", "Acceptable", "Poor"), "</b></div>"
    ))
  })
  
  output$india_map <- renderLeaflet({
    leaflet(cities_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 78.9629, lat = 20.5937, zoom = 4) %>%
      addCircleMarkers(
        lng = ~lng, lat = ~lat, 
        layerId = ~id, # Crucial for shiny interception
        popup = ~paste("<b>", id, "</b><br>Click to load offers!"),
        radius = 8, color = "#2eb872", stroke = FALSE, fillOpacity = 0.8
      )
  })
}

shinyApp(ui, server)
