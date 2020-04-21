library(shinydashboard)
library(shinydashboardPlus)
library(plotly)

sidebar <- dashboardSidebar(
    sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Cumulative View", tabName = "track", icon = icon("signal")),
    menuItem("More Information", tabName = "info", icon = icon("info"))
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "dashboard",
                # Value boxes
                fluidRow(
                    valueBoxOutput("num_case_box"),
                    valueBoxOutput("death_count")
                ),
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
        tabItem(tabName = "track",
                fluidRow(
                    boxPlus(title = "Cumulative Confirmed Cases",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotlyOutput("num_case_line")),
                    boxPlus(title = "Cumulative COVID-19 Related Deaths",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotlyOutput("death_line")),
                    boxPlus(title = "Daily Confirmed Cases",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotlyOutput("daily_num_case_line")),
                    boxPlus(title = "Daily Deaths",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            plotlyOutput("daily_death_line"))
                    
        )),
        tabItem(tabName = "info",
                fluidRow(
                    box(includeMarkdown('info.md'), width = 12))
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