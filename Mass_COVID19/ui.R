library(shinydashboard)

sidebar <- dashboardSidebar(
    checkboxInput("perc_box", "Show in %", FALSE),
    sidebarMenuOutput("menu")
)

body <- dashboardBody(
    # Value boxes
    fluidRow(
        valueBoxOutput("num_case_box"),
        valueBoxOutput("death_count")
    ),
    # Boxes need to be put in a row (or column)
    fluidRow(
        box(plotOutput("county_bar")),
        box(plotOutput("gender_bar")),
        box(plotOutput("age_bar"))
    ))
    
dashboardPage(
    dashboardHeader(title = "Massachusetts COVID-19 Cases", 
                    titleWidth = 350),
    sidebar,
    body
)