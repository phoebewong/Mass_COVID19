library(shinydashboard)
library(shinydashboardPlus)
library(plotly)

sidebar <- dashboardSidebar(
    sidebarMenu(
    menuItem("Overview", tabName = "track", icon = icon("signal")),
    menuItem("City", icon = icon("building"), startExpanded=TRUE,
             menuSubItem("Numbers", tabName = "city"),
             menuSubItem("Map", tabName = "map")),
    menuItem("Numbers by Demo Group", tabName = "demo", icon = icon("user")),
    # menuItem("Map", tabName = "map", icon = icon("map")),
    menuItem("More Information", tabName = "info", icon = icon("info"))
    )
)

body <- dashboardBody(
    tabItems(
        
        #### Overview tab ####
        tabItem(tabName = "track",
                # Value boxes
                fluidRow(
                    valueBoxOutput("num_case_box"),
                    valueBoxOutput("death_count")
                ),
                fluidRow(
                    boxPlus(title = "Number of Confirmed Cases and Deaths - Cumulative and Daily",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            width = 6,
                            plotlyOutput("num_case_overlay"),
                            plotlyOutput("death_overlay")
                            ),
                    boxPlus(title = "Daily Confirmed Cases and Deaths Only",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            width = 6,
                            # plotlyOutput("death_overlay")
                            plotlyOutput("daily_num_case_line"),
                            plotlyOutput("daily_death_line")
                            )
        )),
        #### City tab ####
        tabItem(tabName = "city",
                fluidRow(
                    boxPlus(title = "Number of Confirmed Cases by City",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            # width = 12,
                            plotOutput("city_trace_num")
                    ),
                    boxPlus(title = "Rate (per 100k) by City",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            # width = 12,
                            plotOutput("city_trace_rate")
                    )
                    )
                ),
                
        #### Demo group tab ####
        tabItem(tabName = "demo",
                # Boxes need to be put in a row (or column)
                fluidRow(
                    checkboxInput("perc_box", "Show in %", FALSE),
                    boxPlus(title = "County",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotOutput("county_bar")
                    ),
                    # box(plotOutput("county_bar"), status = 'info', solidHeader = TRUE),
                    boxPlus(title = "Gender",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotOutput("gender_bar")),
                    boxPlus(title = "Age Group",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotOutput("age_bar")),
                    boxPlus(title = "City (Weekly Update)",
                            footer = "Last update: 4/14/2020",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            sliderInput("top_num", "Number of cities to show",
                                        min = 0, max = 352, value = 20),
                            plotOutput("city_bar"),
                            checkboxInput("topcount", "Show in absolute count", FALSE))
                )),
        #### Map ####
        tabItem(tabName = "map",
                # Boxes need to be put in a row (or column)
                fluidRow(
                    # imageOutput("map_city", width = '10px')
                    h3("Map - City (As of Apr 22, updated every Wed)"),
                    img(src = "covid19_422.png", width = '1300 px'),
                    h5("Created by Jessy Han")
                    )
                ),

        #### Info tab ####
        tabItem(tabName = "info",
                fluidRow(
                    box(includeMarkdown('info.md'), width = 12),
                    boxPlus(title = "Linear Regression: County Population and Confirmed Cases",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            width = 12,
                            plotOutput("county_per_cap_reg_line"),
                            footer = "Using number of cases from April 19 and census data for population")
                    )
                )
    )
)
    
dashboardPage(
    skin = "green",
    dashboardHeader(title = "Massachusetts COVID-19 Cases", 
                    titleWidth = 350),
    sidebar,
    body
)