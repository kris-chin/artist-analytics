page_map <- function(raw_data) {

    shiny_page <- NULL

    shiny_page$ui <- fluidPage(
        titlePanel("Map"),

        sidebarLayout(
            sidebarPanel(

            ),

            mainPanel(
                outputId = "map"
            )
        )
    )

    shiny_page$server <- function(input, output) {
        output$map <- renderPlot({
            ggplot2(
                data = display_data(),
            ) +
            geom_map()
        })
    }

    return(shiny_page)
}