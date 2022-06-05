#This UI component is responsible for setting up modular factors in the data
#NOTE: This must be called ONCE in server(). 
ui_modularfactors <- function(input, input_data) {

    #This is our outputted object
    o <- NULL

    #Our selectable categories
    #NOTE: don't make this dynamic. otherwise we could be vulnerable to HTML injection
    categories <- c("store", "country")

    #Helper function
    generate_inputIdString <- function(category_string, number){
        paste("checkbox_", category_string, "_", number, sep="")
    }

    #Returns the complete list of checkbox tags
    #We will hide the tags with JS. not re-render them.
    generate_checkboxes <- function(){

        #We take an empty string that we append RAW html to.
        #This is not vulnerable to HTML injection because we don't actually pass input
        checkbox_html_string <- ""

        #Iterate through every category. Create a div for each one
        for (category in categories){
            #HTML string of the checkboxes within the cateogry
            cat_html_string <- ""

            #helper variable
            unique_categories <- unique(input_data[[category]])

            #Go through every group in the category and create a checkbox.
            for (i in seq_len(length(unique_categories))){
                
                #the inputID of the tag is actually referenced by a numerical value,
                #this means there is no potential for HTML injection
                inputId_string <- generate_inputIdString(category, i)

                #First, generate the actual input tag
                input_tag <- shiny::tags$input(
                    id = inputId_string,
                    type = "checkbox",
                    checked = TRUE, #default to checked
                    class = "shiny-bound-input" #use the shiny styles
                )

                #Wrap the input tag alongside a span tag within a label tag
                label_tag <- shiny::tags$label(
                    list(
                        input_tag,
                        shiny::tags$span(unique_categories[i])
                    )
                )

                #Wrap the label tag within two div tags related to shiny styling
                div_wrappers <- shiny::tags$div(
                    class = "form-group shiny-input-container",
                    shiny::tags$div(
                        class = "checkbox",
                        label_tag
                    )
                )

                #Append our raw HTML to the string
                cat_html_string <- paste(cat_html_string, as.character(div_wrappers))
            }

            #Wrap all of the checkboxes for the respective category in a div
            cat_div_id <- paste("checkboxGroup_", category, sep = "")
            cat_div <- shiny::tags$div(
                id = cat_div_id,
                HTML(cat_html_string)
            )

            #Set up the cat div to be intialized as "hidden" (toggled later)
            cat_div <- shinyjs::hidden(cat_div)

            #Append our div to the overall checkbox string
            checkbox_html_string <- paste(checkbox_html_string, as.character(cat_div) )

        }

        return(HTML(checkbox_html_string))
    }


    #Set up an observer on the page that watches our factor_category variable
    shiny::observeEvent(input$factor_category, {

        #Go through every category and determine if to hide or show their checkboxes
        for (category in categories){
            
            cat_div_id <- paste("checkboxGroup_", category, sep = "")
            
            if (category == input$factor_category){
                shinyjs::show(id = cat_div_id) 
            } else{
                shinyjs::hide(id = cat_div_id)
            }
        }
    })


    #A RenderUI Component that wraps all of the UI
    #Remember that this is called within server()
    o$ui_render <- function() {

        ui_out <- renderUI({

            #wrap within a taglist so they can all be in a single element
            tagList(
                
                #A div element containing a bunch of checkboxes
                tags$div(class = "category_checkboxes",
                    style = "
                        height: 300px;
                        overflow-x: hidden;
                        overflow-y: scroll;
                    ",
                    generate_checkboxes()
                ),
                
                #A select input whose choices are all possible categories (flexible)
                selectInput(
                    inputId = "factor_category",
                    label = NULL,
                    choices = categories,
                    selected = categories[1]
                ),

                #A checkbox input that automatically selects all possible categories
                # checkboxInput(
                #     inputId = "select_all_categories",
                #     label = "Select all categories?",
                #     value = FALSE
                # ),

                #A raw text box that displays all showing categories (eg: "showing: store, country")
                textOutput(
                    outputId = "current_categories_shown"
                )

            )

        })

        return(ui_out)
    }

    #Define our selected categories outside. This will be accessed later
    #This value contains all categories to be displayed
    selected_categories <- shiny::reactiveVal(value = list(NULL))
    #sSet up an Observe that is called EVERY time a new checkbox is checked
    shiny::observe({
        #We will make a list of all selected categories
        #Add every selected category to our list
        for (category in categories){
            unique_categories <- unique(input_data[[category]])
            
            for (i in seq_len(length(unique_categories))) {
                #get the id of the checkbox
                checkbox_id <- generate_inputIdString(category, i)

                #if the respective checkbox is checked, add it to the list
                if (!is.null(input[[checkbox_id]])){
                    group_name <- unique_categories[i]

                    #The following is the handling for adding or removing categories to the plot
                    if (
                        (input[[checkbox_id]] == TRUE) & #checkbox is checked
                        (!is.element(group_name, selected_categories())) #haven't added element yet
                    ){
                        #Update selected_categories()
                        selected_categories_newValue <- append(selected_categories(), group_name)
                        selected_categories(selected_categories_newValue)

                    } else if (
                        (input[[checkbox_id]] == FALSE) & #checkbox is unchecked
                        (is.element(group_name, selected_categories()))  #element was previously selected
                    ){
                        #Update selected_categories()
                        selected_categories_newValue <- selected_categories()[names(selected_categories()) != group_name]
                        selected_categories(selected_categories_newValue)
                    }

                }

            }
        }
    })

    #A function on the backend that modifies the input_data
    o$filter_data <- function() {

        #TODO: apply a union vs intersect option
        #TODO: make this go through ALL categories.. not typed out like it is right now

        #Apply our filter
        return_data <- dplyr::filter(
            .data = input_data, 
            is.element(store, selected_categories()) & is.element(country, selected_categories())
        )
        return(return_data)
    }


    return(o)

}