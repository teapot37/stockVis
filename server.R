# server.R

library(quantmod)
source("helpers.R")
library(lattice)
library(mime)



shinyServer(function(input, output, session) {

  symb <- stockSymbols()
  symb$Symbol <- gsub("-", "", symb$Symbol)  #some symbols are returned with hyphens, which Yahoo doesn't use
  symb$Name <- gsub("&#39;", "\'", symb$Name)
  symb$Description <- paste(symb$Symbol, symb$Name, sep=': ')
  
  thm <- chart_theme()
  thm$col$line.col <- 'blue'

  observe({
    exch <- symb[symb$Exchange == input$exchange,]
    narrow <- exch[grepl(input$symb1, exch$Description, ignore.case=T),]
    choices <- narrow$Description
    updateSelectInput(session, "stock1", choices=choices)
    narrow2 <- exch[grepl(input$symb2, exch$Description, ignore.case=T),]
    choices2 <- narrow2$Description
    updateSelectInput(session, "stock2", choices=choices2)
  })
  
  dataInput1 <- reactive({
    stock1 <- symb$Symbol[symb$Description == input$stock1]
    save1 <- getSymbols(stock1, src = "yahoo", 
                         from = input$dates[1],
                         to = input$dates[2], 
                         auto.assign = FALSE)
  })
  
  finalInput1 <- reactive({
    if (!input$adjust) return(dataInput1())
    adjust(dataInput1())
  })
  
  dataInput2 <- reactive({  
    stock2 <- symb$Symbol[symb$Description == input$stock2]
    save2 <- getSymbols(stock2, src = "yahoo", 
                         from = input$dates[1],
                         to = input$dates[2], 
                         auto.assign = FALSE)
  })
  
  finalInput2 <- reactive({
    if (!input$adjust) return(dataInput2())
    adjust(dataInput2())
  })
  

  
  output$plot <- renderPlot({
    stock1 <- symb$Symbol[symb$Description == input$stock1]
    stock2 <- symb$Symbol[symb$Description == input$stock2]
    chart_Series(Cl(finalInput1()), 
                 type='line', 
                 theme=thm, 
                 name=paste(stock1," (blue) vs. ", stock2," (orange)"))
    add_Series(Cl(finalInput2()), on=1)
  })
})