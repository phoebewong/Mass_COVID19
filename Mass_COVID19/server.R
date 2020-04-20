library(shinydashboard)
library(tidyverse)
library(docxtractr)
library(ggthemes)

palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]][["Tableau 10"]]

#### Read in data ####
df <- read_docx("data/covid-19-case-report-4-18-2020.docx")
tbls <- docx_extract_all_tbls(df)
tbls[[1]] <- tbls[[1]] %>% 
    rename(category = CATEGORY,
           num_case = NUMBER.OF.CONFIRMED.CASES) %>% 
    mutate(num_case = as.numeric(num_case)) # change to numeric

function(input, output) {
    #### Menu help text ####
    output$menu <- renderMenu({
        # Invalidate (and re-run) this code once every second
        invalidateLater(1000*60*60)
        
        sidebarMenu(
            menuItem(Sys.Date())
        )
    })
    #### County plot ####
    output$county_bar <- renderPlot({
        #### Preprocess ####
        county_df <- tbls[[1]]
        # Remove unrelated rows, before "Sex"
        county_df <- county_df[2:(which(county_df$category == "Sex")-1),]
        
        # Rename column
        county_df <- county_df %>% 
            mutate(category = fct_reorder(category, desc(num_case)))
        
        #### Plot ####
        county_bar <- county_df %>% 
            ggplot(aes(x = category, y = num_case)) +
            geom_bar(stat = "identity", fill = palettes$value[1]) +
            geom_text(aes(label = num_case), vjust = -0.3, size = 3) +
            labs(x = "", y = "Number of Cases", title = "Number of COVID-19 cases in Massachusetts") +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45), 
                  axis.title.x = element_blank())
        county_bar
    })
    
    #### Gender plot ####
    output$gender_bar <- renderPlot({
        #### Preprocess ####
        gender_df <- tbls[[1]]
        # Remove unrelated rows, before "Sex"
        gender_df <- gender_df[(which(gender_df$category == "Sex")+1):(which(gender_df$category == "Age Group")-1),]
        
        # Rename column
        gender_df <- gender_df %>% 
            mutate(gender = fct_reorder(category, desc(num_case)))
        
        #### Plot ####
        gender_bar <- gender_df %>% 
            mutate(perc=num_case/sum(num_case)) %>%
            ggplot(aes(x=category, y = perc)) +
            geom_bar(stat = "identity", fill = palettes$value[1]) +
            geom_text(aes(y = perc, label = scales::percent(perc)), vjust = -0.4, size = 4) +
            labs(x = "", y = "Number of Cases", title = "Number of COVID-19 cases in Massachusetts - Gender") +
            scale_y_continuous(labels = scales::percent) +
            scale_fill_tableau() +
            theme_minimal() +
            theme(axis.title.x = element_blank())
        gender_bar
        
    })
    

}