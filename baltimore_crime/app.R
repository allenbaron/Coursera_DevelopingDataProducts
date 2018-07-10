library(shiny)
library(RSocrata)
library(tidyverse)
library(lubridate)
library(RColorBrewer)

# access Open Baltimore, Socrata Open Data API (SODA)
crime <- read.socrata(
    url = "https://data.baltimorecity.gov/resource/4ih5-d5d5.csv?$select=CrimeDate, Description",
    app_token = "5vbefeNa3fjcaHcvAcNNI9u4E"
)

# combine subtypes into single type
crime <- crime %>%
    mutate(
        date = as_date(ymd_hms(CrimeDate)),
        type = str_to_title(
            case_when(
                grepl(".*ASSAULT.*", Description) ~ "ASSAULT",
                grepl(".*LARCENY.*", Description) ~ "LARCENY",
                grepl(".*ROBBERY.*", Description) ~ "ROBBERY",
                TRUE ~ Description
            )
        )
    )

# identify unique crimes
crime_list <- crime$type %>%
    unique() %>%
    sort()

# define color scale for unique crimes (maintain consistency among plots)
myColors <- brewer.pal(9, "Set1")
names(myColors) <- crime_list
myColors <- c(myColors, TOTAL = "#000000")

ui <- fluidPage(
    
    titlePanel("Baltimore Violent Crime over Time"),
    
    sidebarLayout(
        sidebarPanel(
            dateRangeInput(
                inputId = "timeframe",
                label = "Timeframe:",
                start = "2017-01-01",
                end = "2018-01-01",
                min = min(crime$date),
                max = max(crime$date)
            ),
            selectInput(inputId = "compare",
                        label = "Compare:",
                        choices = c("Counts", "Distributions"),
                        selected = "Counts"
            ),
            checkboxGroupInput(
                inputId = "types",
                label = "Crimes to Include:",
                choices = crime_list,
                selected = c("Assault", "Homicide", "Shooting")
            ),
            checkboxInput(inputId = "total", label = "TOTAL")
        ),
        
        mainPanel(
            plotOutput(outputId = "plot")
        )
    )
)

server <- function(input, output) {
    
    date_subset <- reactive({
        filter(
            crime,
            between(date, ymd(input$timeframe[1]), ymd(input$timeframe[2]))
        )
    })
    
    type_subset <- reactive({
        filter(date_subset(), type %in% input$types)
    })
    
    # Set calculated value & y-axis name based on 'Compare' choice
    stat <- reactive({
        if_else(input$compare == "Counts", "..count..", "..density..")
    })
    y_name <- reactive({
        if_else(input$compare == "Counts", "Count", "Density")
    })
    
    output$plot <- renderPlot({
        g <- ggplot(data = type_subset()) +
            geom_freqpoly(
                mapping = aes_string(x = "date", y = stat(), color = "type"),
                binwidth = 30,
                size = 1) +
            labs(x = "Date", y = y_name())
        
        if(input$total) { # include TOTAL?
            g <- g + geom_freqpoly(
                data = date_subset(),
                mapping = aes_string(x = "date", y = stat(), color = '"TOTAL"'),
                binwidth = 30,
                size = 1)
        }
        print(g + scale_colour_manual(name = "Type", values = myColors))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

