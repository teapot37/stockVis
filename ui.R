library(shiny)
library(quantmod)

symb <- stockSymbols()
symb$Symbol <- gsub("-", "", symb$Symbol)  #some symbols are returned with hyphens, which Yahoo doesn't use
symb$Name <- gsub("&#39;", "\'", symb$Name)
symb$Description <- paste(symb$Symbol, symb$Name, sep=': ')

shinyUI(fluidPage(
  titlePanel("Stock Compare"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Select stocks to examine. 
        Information will be collected from Yahoo Finance."),
      helpText("First select your exchange (AMEX, NASDAQ, or NYSE).
        Then either select a company via the drop-down menus or enter a pattern to search."),

      selectInput("exchange", "Exchange:", unique(symb$Exchange), selected="NYSE"),

      br(),
      br(),
      
      selectInput("stock1", "Stock 1:", choices=c("foo", "bar", "baz")),
      textInput("symb1", "Pattern (Company 1)", "WWE"),
      
      selectInput("stock2", "Stock 2:", choices=c("foo", "bar", "baz")),
      textInput("symb2", "Pattern (Company 2)", "MSO"),
      
      dateRangeInput("dates", 
        "Date range",
        start = "2013-01-01", 
        end = as.character(Sys.Date())),
      
      br(),
      br(),
      
      checkboxInput("adjust", 
        "Adjust prices for inflation", value = FALSE)
    ),
    
    mainPanel(
      plotOutput("plot")
#       textOutput("text1")
      )
  )
))