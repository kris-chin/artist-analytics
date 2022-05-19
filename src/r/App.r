library(shiny)
library(ggplot2)
library(lubridate)
library(DT)

#Change port so it's the same every time
options(shiny.port = 8888, shiny.host = "0.0.0.0")

#Get Data
merged_data <- read.csv(
    file = "/app/output/merged_dataframe.csv",
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

            conditionalPanel(
                condition = "input.aggregate_x == true",
                selectInput(
                    inputId = "aggregate_method",
                    label = "Aggregate Method",
                    choices = c("Category", "Complete"),
                    selected = "Category"
                )
            ),

            verbatimTextOutput("click_info"),

            selectInput(
                inputId = "graph_type",
                label = "Graph Type",
                choices = c("Scatterplot", "Line", "Stacked Bar")
            ),

            sliderInput(
                inputId = "date_range",
                label = "Date Range",
                min = merged_data$sale_month[1],
                max = Sys.Date(),
                value = c( merged_data$sale_month[1], Sys.Date()),
                timeFormat = "%Y-%m"
            )
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

        #Get only a specifc date range of the data
        return_data <- merged_data[
            merged_data$sale_month >= input$date_range[1] & merged_data$sale_month <= input$date_range[2],
        ]

        #Aggregate data
        if (input$aggregate_x == TRUE) {
            #If Y value is NOT numerical
            if (!is.numeric(return_data[[input$y]])){
                print(paste("Y-Value '", input$y, "' is not numerical!"))
            } else {

                #Aggregate depending on aggregation strategy
                if (input$aggregate_method == "Category") { #Aggregate by category
                    return_data <- aggregate(
                        #Explanation for '~': LHS = what to compute for, RHS what to aggregate by
                        return_data[[input$y]] ~ return_data[["sale_month"]] + return_data[["store"]],
                        FUN = sum
                    )

                    return_data <- setNames(return_data,
                        c("sale_month", "store", input$y)
                    )
                } else if (input$aggregate_method == "Complete"){ #Completely combine everything
                    return_data <- aggregate(
                        return_data[[input$y]] ~ return_data[["sale_month"]], #If they share the same "sale_month"
                        FUN = sum
                    )

                    return_data <- setNames(return_data,
                        c("sale_month", input$y)
                    )
                }
            }
        }

        return_data
    })

    #Change the way we display the graph
    #Returns a ggplot + geom_ function that can be added upon 
    graph_type <- reactive({
        #Call display_data() once to save calls
        data <- display_data()

        if (input$graph_type == "Scatterplot") {
            ggplot(data = data,
                mapping = aes_string(x = "sale_month", y = input$y)
            ) +
            geom_point(
                aes(color = data$store)
            )
        } else if (input$graph_type == "Line") {

            stores <- factor(data$store)
            if (length(stores) == 0) {
                stores <- NULL
            }

            #Start with the plot
            p <- ggplot(data = data,
                mapping = aes_string(x = "sale_month", y = input$y),
                group = stores
            )

            #Display ggplot
            p + geom_line(aes(color = stores))

        } else if (input$graph_type == "Stacked Bar") {

            #Add fill handling for if there is no categorical variable
            fill <- factor(data$store)
            if (length(fill) == 0) { #if there is no store column
                fill <- NULL
            }

            ggplot(data = data,
                mapping = aes_string(
                    x = "sale_month",
                    y = input$y,
                    fill = fill
                )
            ) +
            geom_bar(
                position = "stack",
                stat = "identity"
            )
        }
    })

    #Plot title
    dynamic_title <- reactive({
        paste("Data for '", filter_value(), "'")
    })

    #By setting output's scatterplot variable, we link it to the ui
    output$scatterplot <- renderPlot({
        graph_type() +
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