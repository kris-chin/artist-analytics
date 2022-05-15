library(shiny)
library(ggplot2)
library(lubridate)
library(DT)

#Change port so it's the same every time
options(shiny.port = 8888)

#Get Data
merged_data <- read.csv(
    file = "output/merged_dataframe.csv",
    header = TRUE,
    stringsAsFactors = FALSE

)

#First use lubridate to parse the date into a POSIX date,
#then convert to date object
merged_data$sale_month <- as.Date(parse_date_time(merged_data$sale_month, "ym"))

#UI
ui <- fluidPage(

    #App Title
    titlePanel("Artist-Analytics"),

    #Display a layout with a sidebar
    sidebarLayout(

        #Provide a space for us to change our Inputs
        sidebarPanel(

            selectInput(
                inputId = "column_filter",
                label = "Filter by:",
                choices = c("artist", "isrc", "song_title"),
                selected = "artist"
            ),

            #Show this panel if "Artist Name" is selected
            conditionalPanel(
                condition = "input.column_filter == 'artist'",
                selectInput(
                    inputId = "filter_artist",
                    label = "Artist",
                    choices = unique(merged_data$artist),
                    selected = unique(merged_data$artist)[1]
                )
            ),

            conditionalPanel(
                condition = "input.column_filter == 'isrc'",
                selectInput(
                    inputId = "filter_isrc",
                    label = "ISRC",
                    choices = unique(merged_data$isrc),
                    selected = unique(merged_data$isrc)[1]
                )
            ),

            conditionalPanel(
                condition = "input.column_filter == 'song_title'",
                selectInput(
                    inputId = "filter_songTitle",
                    label = "Song Title",
                    choices = unique(merged_data$song_title),
                    selected = unique(merged_data$song_title)[1]
                )
            ),

            selectInput(
                inputId = "y",
                label = "Y-axis",
                choices = colnames(merged_data),
                selected = "quantity"
            ),

            checkboxInput(
                inputId = "aggregate_x",
                label = "Aggregate values that share same X value",
                value = FALSE
            ),

            verbatimTextOutput("click_info")
        ),

        #Main Display (output)
        mainPanel(
            plotOutput(
                outputId = "scatterplot",
                click = "plot_click"
            ),
            dataTableOutput(
                outputId = "table"
            )
        )
    )
)

#Server
server <- function(input, output) {

    #Get the data from our conditoinal filter
    filter_value <- reactive({
        if (input$column_filter == "artist") {
            input$filter_artist
        } else if (input$column_filter == "song_title") {
            input$filter_songTitle
        } else if (input$column_filter == "isrc") {
            input$filter_isrc
        }
    })

    #Get data based off of our input values
    display_data <- reactive({
        #Get data based on filter
        return_data <- merged_data[merged_data[[input$column_filter]] == filter_value(), ]

        #Aggregate data?
        if (input$aggregate_x == TRUE) {
            #If Y value is NOT numerical
            if (!is.numeric(return_data[[input$y]])){
                print(paste("Y-Value '", input$y, "' is not numerical!"))
            } else {
                return_data <- aggregate(
                    return_data[[input$y]],
                    list(return_data[["sale_month"]]),
                    FUN = sum
                )

                return_data <- setNames(return_data,
                    c("sale_month", input$y)
                )
            }
        }

        return_data
    })

    #Plot title
    dynamic_title <- reactive({
        paste("Data for '", filter_value(), "'")
    })

    #By setting output's scatterplot variable, we link it to the ui
    output$scatterplot <- renderPlot({
        ggplot(data = display_data(),
            mapping = aes_string(x = "sale_month", y = input$y)
        ) +
        geom_point(
            aes(color = display_data()$store)
        ) +
        ggtitle(dynamic_title()) +
        scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
        theme(
            axis.text.x = element_text(angle = 60, hjust = 1)
        )
    })

    output$table <- renderDataTable({
        DT::datatable(
            data = display_data(),
            options = list(
                scrollX = T
            )
        )
    })

    output$click_info <- renderText({
        paste0("x=", input$plot_click$x, "\ny=", input$plot_click$y)
    })
}

#Create Shiny App by combining UI and Server
shinyApp(ui = ui, server = server)