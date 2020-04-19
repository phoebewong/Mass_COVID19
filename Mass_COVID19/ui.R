library(shinydashboard)

sidebar <- dashboardSidebar(
    sidebarMenuOutput("menu")
)

body <- dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
        box(plotOutput("county_bar"), width = 12)#,
        # box(
        #     title = "Controls",
        #     sliderInput("slider", "Number of observations:", 1, 100, 50)
        # )
    ))
    
dashboardPage(
    dashboardHeader(title = "Massachusetts COVID-19 Cases", 
                    titleWidth = 350),
    sidebar,
    body
)