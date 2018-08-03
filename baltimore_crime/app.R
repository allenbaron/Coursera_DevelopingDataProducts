library(shiny)
library(RSocrata)
library(tidyverse)
library(lubridate)
library(hues)

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

# define color scale for unique crimes (to maintain consistency among plots)
myColors <- iwanthue(11)
names(myColors) <- c(
    "Total -\n All\n Crimes",
    "Total - \n Selected\n Crimes",
    crime_list
)

ui <- fluidPage(
    
    titlePanel("Violent Crime Trends in Baltimore, Maryland, USA",
               windowTitle = "Crime Trends"),
    
    sidebarLayout(
        sidebarPanel(
            # Select x-axis scale (date)
            dateRangeInput(
                inputId = "timeframe",
                label = "Select a timeframe:",
                start = max(crime$date) - years(1),
                end = max(crime$date),
                min = min(crime$date),
                max = max(crime$date)
            ),
            # Select x-axis binning
            selectInput(inputId = "bin_by",
                        label = "Plotted by:",
                        choices = c("Day", "Week", "Month", "Year"),
                        selected = "Week"
            ),
            # Select type of plot
            selectInput(inputId = "compare",
                        label = "Comparing:",
                        choices = c("Counts", "Distribution"),
                        selected = "Counts"
            ),
            # Select crimes to include
            checkboxGroupInput(
                inputId = "types",
                label = "Including these crime:",
                choices = crime_list,
                selected = c("Assault", "Homicide", "Shooting")
            ),
            # Plot total of selected crimes
            checkboxInput(inputId = "subtotal", label = "Total - SELECTED crimes"),
            # Plot total of all crimes
            checkboxInput(inputId = "total", label = "Total - ALL crimes")
        ),
        
        mainPanel(
            plotOutput(outputId = "plot"),
            tabsetPanel(type = "pills",
                tabPanel(
                    title = "Description",
                    HTML(
                        "<h4>App Description</h4>
                        <p>This app is designed to help users explore trends in violent 
                        crime that occurred in Baltimore, Maryland, USA. The source 
                        code is available on <a href='https://github.com/allenbaron/Coursera_DevelopingDataProducts'>Github</a>.</p>
                        <h4>Data Source</h4>
                        <p>The data powering this app is collected and made publicly 
                        available by the Baltimore Police Department on Baltimore's 
                        Open Data portal, <a href='https://data.baltimorecity.gov/'>
                        Open Baltimore</a>, as 
                        <a href='https://data.baltimorecity.gov/Public-Safety/BPD-Part-1-Victim-Based-Crime-Data/wsfq-mvij'>
                        Part 1 Victim Based Crime Data</a>.<br>
                        For more information about the data, follow the link to the data set."
                    )
                ),
                tabPanel(
                    title = "How To ...",
                    HTML(
                "<h4>How to Customize the Plot</h4>
                <ol>
                    <li>Select a start and end date of data to plot.
                        <ul>
                            <li>Data are available from ",
                                as.character(min(crime$date)), " to ",
                                as.character(max(crime$date)), ".</li>
                        </ul>
                    </li>
                    <li>Choose the time period you'd like to group crimes into: 
                        day, week, month, or year.</li>
                    <li>Choose whether you'd like to compare the count or 
                        distribution of the data.
                        <ul>
                            <li><b>Count</b> is the number of crimes per period.</li>
                            <li><b>Distribution</b> is the <i>density</i> of 
                                crimes per period. Choose this to compare 
                                trends in crimes with very different counts.</li>
                        </ul>
                    </li>
                    <li>Select crime types.</li>
                    <li>Choose whether to include crime totals.
                        <ul>
                            <li><b>Total - SELECTED crimes</b> is the total of 
                                crimes <i>currently</i> on the plot.</li>
                            <li><b>Total - ALL crimes</b> is the total of all 
                                crimes in the data set.</li>
                        </ul>
                    </li>
                </ol>"
                    )
                )
            )
        )
    )
)

server <- function(input, output) {
    
    # Set x-axis scale (date)
    date_subset <- reactive({
        filter(
            crime,
            between(date, input$timeframe[1], input$timeframe[2])
        )
    })
    
    # Set x-axis binning
    bin <- reactive({
        case_when(
            input$bin_by == "Day" ~ 1,
            input$bin_by == "Week" ~ 7,
            input$bin_by == "Month" ~ 365/12,
            input$bin_by == "Year" ~ 365
        )
    })
    
    # Subset to selected crimes
    type_subset <- reactive({
        filter(date_subset(), type %in% input$types)
    })
    
    # Set calculated value & y-axis name based on selected plot type
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
                binwidth = bin(),
                size = 1) +
            labs(x = "Date", y = y_name())
        # Include Total of ALL crimes
        if(input$subtotal) { 
            g <- g + geom_freqpoly(
                data = type_subset(),
                mapping = aes_string(x = "date", y = stat(),
                                     color = '"Total - \n Selected\n Crimes"'),
                binwidth = bin(),
                size = 1)
        }
        # Include Total of SELECTED crimes
        if(input$total) { 
            g <- g + geom_freqpoly(
                data = date_subset(),
                mapping = aes_string(x = "date", y = stat(),
                                     color = '"Total -\n All\n Crimes"'),
                binwidth = bin(),
                size = 1)
        }
        print(g + scale_colour_manual(name = "Crime", values = myColors))
    })
    
}

shinyApp(ui = ui, server = server)

