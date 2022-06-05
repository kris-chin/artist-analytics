library(maps)
library(countrycode)

page_map <- function(raw_data) {

    shiny_page <- NULL

    shiny_page$ui <- fluidPage(
        titlePanel("Map"),

        sidebarLayout(
            sidebarPanel(

            ),

            mainPanel(
                uiOutput(
                    outputId = "map_ui"
                ),
                dataTableOutput(
                    outputId = "map_table"
                )
            )
        )
    )

    shiny_page$server <- function(input, output, session) {

        #This will be our values, and it should be the same lengh as our IDs
        display_data <- reactive({
            return_data <- raw_data

            #NOTE: This is cleaning work that probably should be done on the pipeline instead..

            #Convert all of our ISO2 countrycodes to ISO3
            return_data$country <- countrycode(
                return_data$country,
                "iso2c",
                "iso3c",
                nomatch = return_data$country #leave the already-ISO3 values alone
            )

            #Then convert all of the ISO3 countrycodes to their english names
            return_data$country <- countrycode(
                return_data$country,
                "iso3c",
                "country.name"
            )

            #Aggregate all of the conutry values
            return_data <- aggregate(
                return_data[["quantity"]] ~ return_data[["country"]],
                FUN = sum
            )

            #Rename headers
            return_data <- setNames(return_data,
                nm = c("country", "quantity")
            )

            return_data
        })

        #Get our map data from the maps package
        #Contains "long" and "lat" data
        world_polygon_data <- reactive({
            polygon_data <- map_data("world")

            #Rename some of the regions to match our country names
            #eg. "United States", not "USA"
            #eg2. "Trinidad & Tobago", not "Trinidad","Tobago"
            polygon_data$region[polygon_data$region == "USA"] <- "United States"
            polygon_data$region[polygon_data$region == "UK"] <- "United Kingdom"

            polygon_data
        })

        #get a list of ALL countries, those in our data, and those in the world map
        #These IDs MUST be the same format as the map data
        complete_data <- reactive({
            #first, get our current number of countries
            df_countries <- data.frame(unique(display_data()[["country"]]))
            colnames(df_countries) <- "country" 

            #then, get our map_data's countries
            poly_countries <- data.frame(unique(world_polygon_data()$region))
            colnames(poly_countries) <- "country"

            #merge df_countries into poly_countries, where any missing values are replaced with NA
            #NOTE: we had to convert these lists into dataframes for this merge to work
            merged_countries <- merge(
                y = poly_countries,
                x = display_data(),
                all.y = TRUE, #make sure our total list is the same length as our Y
                sort = TRUE
            )

            #set any NA data to 0
            merged_countries$quantity[is.na(merged_countries$quantity)] <- 0

            #rename "country" to "region"? in an attempt to get ggplot to work
            merged_countries <- setNames(merged_countries, 
                nm = c("region", "quantity")
            )

            #NOTE: this also includes quantities
            merged_countries
        })

        #Lastly, generate a ggplot2 that uses geom_map. Pair our country IDs with their values
        display <- reactive({
            #make a single call
            #SIZE: 252. IDs = "country", VALUES = "quantity"
            df_data <- complete_data()
            #SIZE: 252. IDs = "region"
            poly_data <- world_polygon_data()

            #Man... I don't even know anymore....
            #Literally no input.. I have a feeling it's because of the aes....

            p <- ggplot(
                #A dataframe that contains the values assosiated with each "map_id"
                data = df_data,

                mapping = aes(
                    #what part of the map polygon data is being filled in?
                    map_id = region
                )
            ) +
            geom_map(
                #what are the actual polygons to plot?
                map = poly_data,

                mapping = aes(
                    #What value from the data is filled ?
                    fill = quantity
                )
            ) +
            expand_limits(
                x = poly_data$long,
                y = poly_data$lat
            )
            p
        })

        output$map_ui <- renderUI({
            plotlyOutput(
                outputId = "map"
            )
        })

        output$map <- renderPlotly({
            p <- display()
            ggplotly(p)
        })

        output$map_table <- renderDataTable({
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