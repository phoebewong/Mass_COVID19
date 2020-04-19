library(shinydashboard)
library(tidyverse)
library(docxtractr)
library(ggthemes)

palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]][["Tableau 10"]]

#### Read in data ####
df <- read_docx("../data/covid-19-case-report-4-18-2020.docx")
tbls <- docx_extract_all_tbls(df)

function(input, output) {
    #### Read in data ####
    
    output$county_bar <- renderPlot({
        #### Preprocess ####
        county_df <- tbls[[1]]
        # county_names <- county_df$CATEGORY[2:16] # TODO: update this
        
        # Remove unrelated rows, before "Sex"
        county_df <- county_df[2:(which(county_df$CATEGORY == "Sex")-1),]
        
        # Rename column
        county_df <- county_df %>% 
            rename(county = CATEGORY,
                   num_case = NUMBER.OF.CONFIRMED.CASES) %>% 
            mutate(num_case = as.numeric(num_case), # change to numeric
                   county = fct_reorder(county, desc(num_case)))
        
        #### Plot ####
        county_bar <- county_df %>% 
            ggplot(aes(x = county, y = num_case)) +
            geom_bar(stat = "identity", fill = palettes$value[1]) +
            geom_text(aes(label = num_case), vjust = -0.3, size = 3) +
            labs(x = "", y = "Number of Cases", title = "Number of COVID-19 cases in Massachusetts") +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45))
        county_bar
    })
}