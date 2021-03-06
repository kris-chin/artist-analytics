library(shiny)
library(ggplot2)
library(lubridate)
library(DT)
library(plotly)
library(shinyjs)
library(dplyr)
library(caret)

#Import pages
source("/app/src/r/pages/TimeSeries.r", local = TRUE)
source("/app/src/r/pages/Map.r", local = TRUE)

#Change port so it's the same every time
options(
    shiny.port = 8888,
    shiny.host = "0.0.0.0"
    # shiny.fullstacktrace = TRUE #enable full stack trace. usually doesn't help
)

#Get Data
merged_data <- read.csv(
    file = "/app/output/merged_dataframe.csv",
    header = TRUE,
    stringsAsFactors = FALSE
)
#Use lubridate to parse the date into a POSIX date, then convert to date object
merged_data$sale_month <- as.Date(parse_date_time(merged_data$sale_month, "ym"))


test_points <- read.csv(
    file = "/app/output/test_points.csv",
    header = TRUE,
    stringsAsFactors = FALSE
)
test_points$sale_month <- as.Date(parse_date_time(test_points$sale_month, "ym"))


#Define Pages
timeseries <- page_timeseries(merged_data,
    #Save our test_data in an extra_data object
    test_data = test_points
)
map <- page_map(merged_data)

#UI
ui <- {
    shiny::navbarPage("Artist-Analytics",
        #Enable ShinyJS
        shinyjs::useShinyjs(),
        shiny::tabPanel("Time-Series", timeseries$ui),
        shiny::tabPanel("Map", map$ui)
    )
}

#Server
server <- function(input, output, session) {
    timeseries$server(input, output, session)
    map$server(input, output, session)
}

#Create Shiny App by combining UI and Server
shiny::shinyApp(ui = ui, server = server)