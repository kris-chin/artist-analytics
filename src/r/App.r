library(shiny)
library(ggplot2)
library(lubridate)
library(DT)
library(plotly)

#Import pages
source("/app/src/r/pages/TimeSeries.r", local = TRUE)
source("/app/src/r/pages/Map.r", local = TRUE)

#Change port so it's the same every time
options(
    shiny.port = 8888,
    shiny.host = "0.0.0.0"
)

#Get Data
merged_data <- read.csv(
    file = "/app/output/merged_dataframe.csv",
    header = TRUE,
    stringsAsFactors = FALSE
)

#First use lubridate to parse the date into a POSIX date,
#then convert to date object
merged_data$sale_month <- as.Date(parse_date_time(merged_data$sale_month, "ym"))

#Define Pages
timeseries <- page_timeseries(merged_data)
map <- page_map(merged_data)

#UI
ui <- {
    navbarPage("Artist-Analytics",
        tabPanel("Time-Series", timeseries$ui),
        tabPanel("Map", map$ui)
    )
}

#Server
server <- function(input, output) {
    timeseries$server(input, output)
    map$server(input, output)
}

#Create Shiny App by combining UI and Server
shinyApp(ui = ui, server = server)