library(shinydashboard)
library(tidyverse)
library(docxtractr)
library(ggthemes)

palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]][["Tableau 10"]]

#### Read in data ####
df <- docxtractr::read_docx("data/covid-19-case-report-4-18-2020.docx")
tbls <- docx_extract_all_tbls(df)
tbls[[1]] <- tbls[[1]] %>% 
    rename(category = CATEGORY,
           num_case = NUMBER.OF.CONFIRMED.CASES) %>% 
    mutate(num_case = as.numeric(num_case)) # change to numeric


function(input, output) {
    #### Value boxes ####
    output$num_case_box <- renderValueBox({
        valueBox(tbls[[2]]$Confirmed.CasesN.... %>% last() %>% as.numeric(), 
                 "Reported Confirmed Cases", icon = icon('user-circle'), color = "orange")
    })
    output$death_count <- renderValueBox({
        valueBox(tbls[[2]]$DeathsN.... %>% last() %>% as.numeric(), 
                 "Total Deaths", color = "maroon")
    })
    #### Menu help text ####
    output$menu <- renderMenu({
        # TODO: add last update time
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
            labs(x = "", y = "Number of Cases", title = "Number of cases by County") +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45), 
                  axis.title.x = element_blank(),
                  plot.title = element_text(face = "bold"))
        county_bar
    })
    
    #### Gender plot ####
    output$gender_bar <- renderPlot({
        #### Plot ####
        gender_bar <- gender_df %>% 
            mutate(perc=num_case/sum(num_case)) %>%
            ggplot(aes(x=category, y = perc)) +
            geom_bar(stat = "identity", fill = palettes$value[1]) +
            geom_text(aes(y = perc, label = scales::percent(perc)), vjust = -0.4, size = 4) +
            labs(x = "", y = "Number of Cases", title = "Number of cases by Gender") +
            scale_y_continuous(labels = scales::percent) +
            scale_fill_tableau() +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  plot.title = element_text(face = "bold"))
        gender_bar
        
    })
    

}