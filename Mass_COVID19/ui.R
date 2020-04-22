library(shinydashboard)
library(shinydashboardPlus)
library(plotly)

sidebar <- dashboardSidebar(
    sidebarMenu(
    menuItem("Overview", tabName = "track", icon = icon("signal")),
    menuItem("Numbers By Group", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("More Information", tabName = "info", icon = icon("info"))
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "dashboard",
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
                # Value boxes
                fluidRow(
                    valueBoxOutput("num_case_box"),
                    valueBoxOutput("death_count")
                ),
                fluidRow(
                    boxPlus(title = "Cumulative",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            # width = 12,
                            plotlyOutput("num_case_line"),
                            plotlyOutput("death_line")),
                    # boxPlus(title = "Cumulative COVID-19 Related Deaths",
                    #         solidHeader = FALSE,
                    #         status = 'primary',
                    #         collapsible=TRUE,
                    #         closable=FALSE,
                    #         plotlyOutput("death_line")),
                    boxPlus(title = "Daily",
                            solidHeader = FALSE,
                            status = 'primary',
                            collapsible=TRUE,
                            closable=FALSE,
                            # width = 12,
                            plotlyOutput("daily_num_case_line"),
                            plotlyOutput("daily_death_line"))#,
                    # boxPlus(title = "Daily Deaths",
                            # solidHeader = FALSE,
                            # status = 'primary',
                            # collapsible=TRUE,
                            # closable=FALSE,
                            # plotlyOutput("daily_death_line"))
                            # 
        )),
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