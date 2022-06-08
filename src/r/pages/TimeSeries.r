source("/app/src/r/components/ModularFactors.r", local = TRUE)

page_timeseries <- function(raw_data, test_data) {
    shiny_page <- NULL
    
    #See if any extra data was implemented
    if (missing(test_data)){
        test_data <- NULL
    }

    shiny_page$ui <- shiny::fluidPage(
        #App Title
        shiny::titlePanel("Time Series Analysis"),

        #Display a layout with a sidebar
        shiny::sidebarLayout(

            #Provide a space for us to change our Inputs
            shiny::sidebarPanel(

                shiny::selectInput(
                    inputId = "column_filter",
                    label = "Filter by:",
                    choices = c("artist", "isrc", "song_title"),
                    selected = "artist"
                ),

                #Show this panel if "Artist Name" is selected
                shiny::conditionalPanel(
                    condition = "input.column_filter == 'artist'",
                    shiny::uiOutput(outputId = "select_artist")
                ),

                shiny::conditionalPanel(
                    condition = "input.column_filter == 'isrc'",
                    shiny::uiOutput(outputId = "select_isrc")
                ),

                shiny::conditionalPanel(
                    condition = "input.column_filter == 'song_title'",
                    shiny::uiOutput(outputId = "select_songtitle")
                ),

                shiny::uiOutput(outputId = "select_y"),

                shiny::checkboxInput(
                    inputId = "normalize_values",
                    label = "Normalize Values? (Enables External Y-values)",
                    value = TRUE
                ),

                shiny::selectInput(
                    inputId = "group",
                    label = "Group By",
                    choices = c("store", "country"),
                    selected = "store"
                ),

                shiny::checkboxInput(
                    inputId = "aggregate_x",
                    label = "Aggregate values that share same X value",
                    value = TRUE
                ),

                shiny::conditionalPanel(
                    condition = "input.aggregate_x == true",
                    shiny::selectInput(
                        inputId = "aggregate_method",
                        label = "Aggregate Method",
                        choices = c("Category", "Complete"),
                        selected = "Category"
                    )
                ),

                shiny::conditionalPanel(
                    condition = "(input.normalize_values == true) && (input.aggregate_method == 'Category')",
                    shiny::checkboxInput(
                        inputId = "normalize_categories",
                        label = "Normalize Categories?",
                        value = FALSE
                    )
                ),

                shiny::selectInput(
                    inputId = "graph_type",
                    label = "Graph Type",
                    choices = c("Scatterplot", "Line", "Stacked Bar"),
                    selected = "Line"
                ),

                shiny::uiOutput(
                    outputId = "select_daterange"
                ),

                shiny::uiOutput(
                    outputId ="component_modularfactors"
                )

            ),

            #Main Display (output)
            shiny::mainPanel(
                plotly::plotlyOutput(
                    outputId = "plot",
                ),
                DT::dataTableOutput(
                    outputId = "plot_table"
                )
            )
        )
    )

    shiny_page$server <- function(input, output, session) {

        modularfactors <- ui_modularfactors(input, raw_data)

        #Reactive UI output (seperated from UI)
        output$select_artist <- shiny::renderUI({
            shiny::selectInput(
                inputId = "filter_artist",
                label = "Artist",
                choices = unique(raw_data$artist),
                selected = unique(raw_data$artist)[1]
            )
        })

        output$select_isrc <- shiny::renderUI({
            shiny::selectInput(
                inputId = "filter_isrc",
                label = "ISRC",
                choices = unique(raw_data$isrc),
                selected = unique(raw_data$isrc)[1]
            )
        })

        output$select_songtitle <- shiny::renderUI({
            shiny::selectInput(
                inputId = "filter_songTitle",
                label = "Song Title",
                choices = unique(raw_data$song_title),
                selected = unique(raw_data$song_title)[1]
            )
        })

        output$select_y <- shiny::renderUI({
            list(
                shiny::selectInput(
                    inputId = "y",
                    label = "MAIN Y-axis variable",
                    choices = colnames(raw_data),
                    selected = "quantity"
                ),
                #TODO: secondary y-axis variable (to be displayed on the right-side of the graph)
                shiny::selectInput(
                    inputId = "y2",
                    label = "SECONDARY Y-axis variable (WIP)",
                    choices = c(),
                )
            )

        })

        output$select_daterange <- shiny::renderUI({
            shiny::sliderInput(
                inputId = "date_range",
                label = "Date Range",
                min = raw_data$sale_month[1],
                max = Sys.Date(),
                value = c(raw_data$sale_month[1], Sys.Date()),
                timeFormat = "%Y-%m"
            )
        })

        #Add our ModularFactors component
        output$component_modularfactors <- shiny::renderUI({
            shiny::conditionalPanel(
                condition = "input.aggregate_method == 'Category'",
                modularfactors$ui_render()
            )
        })

        #=========================================================
        #                    Data Transformation
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

            #Get the Filtered Factor data from ModularFactors
            if (input$aggregate_method == "Category"){
                return_data <- modularfactors$filter_data()
            } else {
                return_data <- raw_data
            }

            #Get data based on categorical filter
            return_data <- return_data[return_data[[input$column_filter]] == filter_value(), ]

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

            #Normalize Data via Min-Max Scaling through caret
            if (input$normalize_values == TRUE) {

                #are we doing per-category noramlization or just overall normalization?
                if (input$normalize_categories == TRUE) {
                    
                    #get our groups
                    groups <- unique(return_data[[input$group]])

                    #Iterate through each group
                    for (group_name in groups) {

                        #first, get all values that share the same group name
                        group_data <- return_data[ return_data[[input$group]] == group_name, ]

                        #Check if input$y has near-zero variance (which affects our preprocessing)
                        zerovar_column_numbers <- caret::nearZeroVar(group_data[[input$y]])
                        if (length(zerovar_column_numbers) >= 1){ #if the column has near-zero variance,
                           #remove data that has near-zero variance
                           return_data <- return_data[ return_data[[input$group]] != group_name, ]

                        } else {
                            #next, process the values
                            process <- caret::preProcess(
                                as.data.frame(group_data[[input$y]]),
                                method=c("range")
                            )
                            
                            #next, get our values from the process
                            normalized <- predict(
                                process,
                                as.data.frame(group_data[[input$y]])
                            )

                            #finally, assign these values to our values that match the group
                            return_data[ return_data[[input$group]] == group_name, ][[input$y]] <- unlist(normalized)
                        }


                    }

                } else {
                    #first, do the processing
                    process <- caret::preProcess(
                        as.data.frame(return_data[[input$y]]),
                        method=c("range")
                    )

                    #next, get our values
                    normalized <- predict(
                        process,
                        as.data.frame(return_data[[input$y]])
                    )

                    #finally, assign our values to our data
                    return_data[[input$y]] <- unlist(normalized)
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

                p <- ggplot(data = data,
                    mapping = aes_string(x = "sale_month", y = input$y)
                )

                p <- p + geom_point(
                    aes(color = .data[[input$group]])
                )

                p

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
                p <- p + geom_line(aes(color = groups))

                #Add handling for extra data
                #TODO: Normalize this data and show it as an option on UI
                if (!is.null(test_data)){
                    p <- p + geom_line(
                        data = test_data,
                        mapping = aes_string(
                            x = "sale_month",
                            y = "value"
                        )
                    )
                }

                p

            } else if (input$graph_type == "Stacked Bar") {

                #Add fill handling for if there is no categorical variable
                fill <- factor(data[[input$group]])
                if (length(fill) == 0) { #if there is no group column
                    fill <- NULL
                }

                p <- ggplot(data = data,
                    mapping = aes_string(
                        x = "sale_month",
                        y = input$y,
                        fill = fill
                    )
                )
                p <- p + geom_bar(
                    position = "stack",
                    stat = "identity"
                )

                p
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

        output$plot_table <- renderDataTable({
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