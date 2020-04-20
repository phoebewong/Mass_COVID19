library(shinydashboard)
library(tidyverse)
library(docxtractr)
library(ggthemes)
library(glue)
library(plotly)

palettes <- ggthemes_data[["tableau"]][["color-palettes"]][["regular"]][["Tableau 10"]]

#### Read in data ####
df <- docxtractr::read_docx("data/hist/covid-19-case-report-4-19-2020.docx")
tbls <- docx_extract_all_tbls(df)
tbls[[1]] <- tbls[[1]] %>% 
    rename(category = CATEGORY,
           num_case = NUMBER.OF.CONFIRMED.CASES) %>% 
    mutate(num_case = as.numeric(num_case)) # change to numeric
# City data (weekly)
city_word <- docxtractr::read_docx("data/covid-19-city-town-4-14-2020.docx")
city_df <- docx_extract_all_tbls(city_word)[[1]]

num_case_trace_df <- readRDS("data/hist/num_case_trace_df.rds")

#### server ####
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
    #### TODO: last update time ####
    output$menu_date <- renderMenu({
        # TODO: add actual last update time
        # # Invalidate (and re-run) this code once every second
        # invalidateLater(1000*60*60)
        sidebarMenu(
            menuItem(paste("Last Update:", Sys.Date()))
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
        county_bar <- county_df %>% 
            mutate(perc=num_case/sum(num_case))
        #### Plot ####
        if(input$perc_box){
            county_bar <-  county_bar %>% 
                ggplot(aes(x = category, y = perc)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(y = perc, label = scales::percent(perc)), vjust = -0.4, size = 4) +
                scale_y_continuous(labels = scales::percent) +
                labs(y = "% of Cases", title = "Percentage of cases by County")
        } else {
            county_bar <- county_bar %>% 
                ggplot(aes(x = category, y = num_case)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(label = num_case), vjust = -0.3, size = 3) +
                labs(y = "Number of Cases", title = "Number of cases by County")
        }
        county_bar <- county_bar + 
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45), 
                  axis.title.x = element_blank(),
                  plot.title = element_text(face = "bold"))
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
            mutate(gender = fct_reorder(category, desc(num_case)),
                   perc=num_case/sum(num_case))
        
        #### Plot ####
        if(input$perc_box){
            gender_bar <- gender_df %>%
                ggplot(aes(x = category, y = perc)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(y = perc, label = scales::percent(perc)), vjust = -0.4, size = 4) +
                labs(y = "% of Cases", title = "Percentage of cases by Gender") +
                scale_y_continuous(labels = scales::percent)
        } else {
            gender_bar <- gender_df %>% 
                ggplot(aes(x = category, y = num_case)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(label = num_case), vjust = -0.3, size = 3) +
                labs(y = "Number of Cases", title = "Number of cases by Gender")
        }
        
        gender_bar <- gender_bar +
            scale_fill_tableau() +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  plot.title = element_text(face = "bold"))
        gender_bar
    })
    #### Age plot ####
    output$age_bar <- renderPlot({
        #### Preprocess ####
        age_df <- tbls[[1]]
        # Remove unrelated rows, before "Sex"
        age_df <- age_df[(which(age_df$category == "Age Group")+1):(which(age_df$category == "Deaths")-1),]
        
        # Fix bar order by age group
        age_df <- age_df %>% 
            mutate(category = fct_inorder(category),
                   perc=num_case/sum(num_case))
        
        #### Plot ####
        if(input$perc_box){
            age_bar <- age_df %>% 
                ggplot(aes(x=category, y = perc)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(y = perc, label = scales::percent(perc)), vjust = -0.4, size = 4) +
                labs(x = "", y = "% of Cases", title = "Percentage of cases by Age Group") +
                scale_y_continuous(labels = scales::percent)
        } else {
            age_bar <- age_df %>% 
                ggplot(aes(x = category, y = num_case)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(label = num_case), vjust = -0.3, size = 3) +
                labs(y = "Number of Cases", title = "Number of cases by Age Group")
            
        }
        age_bar <- age_bar +
            scale_fill_tableau() +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle = 45, margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        age_bar
    })
    #### city plot ####
    output$city_bar <- renderPlot({
        city_df <- city_df %>% 
            rename(city = City.Town,
                   count = Count,
                   rate = Rate.) %>% 
            # TODO: clean up less than 5 and 0
            mutate(count = as.numeric(count), 
                   rate = as.numeric(rate)) %>% 
            filter(city != "State Total")
        
        # Top count
        if (input$topcount){
            city_bar <- city_df %>% 
                mutate(city = fct_reorder(city, desc(count))) %>% 
                top_n(input$top_num, count) %>% 
                ggplot(aes(x = city, y = count)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(label = count), vjust = -0.4, size = 4) +
                labs(y = "Number of Cases",
                     title = glue("Top {input$top_num} Cities by Count"))
        } else {
            # top rate
            city_bar <- city_df %>% 
                mutate(city = fct_reorder(city, desc(rate))) %>% 
                top_n(input$top_num, rate) %>% 
                ggplot(aes(x = city, y = rate)) +
                geom_bar(stat = "identity", fill = palettes$value[1]) +
                geom_text(aes(label = round(rate)), vjust = -0.4, size = 4) +
                labs(y = "Number of Cases", title = glue("Top {input$top_num} Cities by Rate"),
                     subtitle = "Rate: # of cases per 100,000 people") 
        }
        city_bar <- city_bar + 
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 45),
                axis.title.x = element_blank(),
                plot.title = element_text(face = "bold"))
        city_bar
    })
    output$num_case_line <- renderPlotly({
        g <- ggplot(num_case_trace_df, aes(x = date, y = total)) +
            geom_line(color = palettes$value[1]) +
            theme_minimal() +
            labs(y = "Number of Confirmed Cases",
                 title = "Cumumlative Number of Confirmed Cases") +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45,margin = margin(t = 20)))
        g <- ggplotly(g)
    })
}