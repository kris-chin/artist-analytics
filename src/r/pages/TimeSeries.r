page_timeseries <- function(raw_data) {
    shiny_page <- NULL

    shiny_page$ui <- fluidPage(
        #App Title
        titlePanel("Time Series Analysis"),

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
                    uiOutput(outputId = "select_artist")
                ),

                conditionalPanel(
                    condition = "input.column_filter == 'isrc'",
                    uiOutput(outputId = "select_isrc")
                ),

                conditionalPanel(
                    condition = "input.column_filter == 'song_title'",
                    uiOutput(outputId = "select_songtitle")
                ),

                uiOutput(outputId = "select_y"),

                selectInput(
                    inputId = "group",
                    label = "Group By",
                    choices = c("store", "country"),
                    selected = "store"
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

                uiOutput(
                    outputId = "select_daterange"
                ),

            ),

            #Main Display (output)
            mainPanel(
                plotlyOutput(
                    outputId = "plot",
                ),
                dataTableOutput(
                    outputId = "table"
                )
            )
        )
    )

    shiny_page$server <- function(input, output) {

        #Reactive UI output (seperated from UI)
        output$select_artist <- renderUI({
            selectInput(
                inputId = "filter_artist",
                label = "Artist",
                choices = unique(raw_data$artist),
                selected = unique(raw_data$artist)[1]
            )
        })

        output$select_isrc <- renderUI({
            selectInput(
                inputId = "filter_isrc",
                label = "ISRC",
                choices = unique(raw_data$isrc),
                selected = unique(raw_data$isrc)[1]
            )
        })

        output$select_songtitle <- renderUI({
            selectInput(
                inputId = "filter_songTitle",
                label = "Song Title",
                choices = unique(raw_data$song_title),
                selected = unique(raw_data$song_title)[1]
            )
        })

        output$select_y <- renderUI({
            selectInput(
                inputId = "y",
                label = "Y-axis",
                choices = colnames(raw_data),
                selected = "quantity"
            )
        })

        output$select_daterange <- renderUI({
            sliderInput(
                inputId = "date_range",
                label = "Date Range",
                min = raw_data$sale_month[1],
                max = Sys.Date(),
                value = c(raw_data$sale_month[1], Sys.Date()),
                timeFormat = "%Y-%m"
            )
        })

        #=========================================================

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
            return_data <- raw_data[raw_data[[input$column_filter]] == filter_value(), ]

            #Get only a specifc date range of the data
            return_data <- return_data[
                return_data$sale_month >= input$date_range[1] & return_data$sale_month <= input$date_range[2],
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
                            return_data[[input$y]] ~ return_data[["sale_month"]] + return_data[[input$group]],
                            FUN = sum
                        )

                        return_data <- setNames(return_data,
                            c("sale_month", input$group, input$y)
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
                    aes(color = .data[[input$group]])
                )
            } else if (input$graph_type == "Line") {

                groups <- factor(data[[input$group]])
                if (length(groups) == 0) {
                    groups <- NULL
                }

                #Start with the plot
                p <- ggplot(data = data,
                    mapping = aes_string(x = "sale_month", y = input$y),
                    group = groups
                )

                #Display ggplot
                p + geom_line(aes(color = groups))

            } else if (input$graph_type == "Stacked Bar") {

                #Add fill handling for if there is no categorical variable
                fill <- factor(data[[input$group]])
                if (length(fill) == 0) { #if there is no group column
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
        output$plot <- renderPlotly({
            p <- graph_type() +
                ggtitle(dynamic_title()) +
                scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
                theme(
                    axis.text.x = element_text(angle = 60, hjust = 1)
                )
            ggplotly(p)
        })

        output$table <- renderDataTable({
            DT::datatable(
                data = display_data(),
                options = list(
                    scrollX = T
                )
            )
        })
    }

    return(shiny_page)
}