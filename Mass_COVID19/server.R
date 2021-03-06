library(shinydashboard)
library(tidyverse)
library(docxtractr)
library(ggthemes)
library(glue)
library(plotly)
library(lubridate)
library(ggpubr)

#### server ####
function(input, output) {
    #### Value boxes ####
    output$num_case_box <- renderValueBox({
        valueBox(last(num_case_trace_df$total), 
                 "Reported Confirmed Cases", icon = icon('user-circle'), color = "orange")
    })
    output$death_count <- renderValueBox({
        valueBox(last(death_trace_df$total), 
                 "Total Deaths", color = "maroon")
    })
    output$test_count <- renderValueBox({
        valueBox(round(last(test_df$pct_pos) * 100, 1), 
                 # subtitle = glue("{round(last(test_df$pct_pos) * 100, 1)} % positive test results"),
                 "% of Positive Results of Tests Performed Today",  icon = icon('file'), color = "teal")
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
        city_df <- city_df_all %>% 
            filter(date == last(date))
            # rename(city = City.Town,
            #        count = Count,
            #        rate = Rate.) %>% 
            # # TODO: clean up less than 5 and 0
            # mutate(count = as.numeric(count), 
            #        rate = as.numeric(rate)) %>% 
            # filter(city != "State Total")  # most up to date
        
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
    #### Tracking ####
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
                  axis.text.x = element_text(angle=45,margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    
    output$daily_num_case_line <- renderPlotly({
        g <- ggplot(num_case_trace_df, aes(x = date, y = daily)) +
            geom_line(color = palettes$value[1]) +
            theme_minimal() +
            labs(y = "Number of Confirmed Cases",
                 title = "Daily Number of Confirmed Cases") +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45, margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    ## Overlay tracking - Num case ##
    output$num_case_overlay <- renderPlotly({
        g <- ggplot(num_case_trace_df) +
            geom_bar(aes(x = date, y = total), stat = "identity", fill = palettes$value[1]) +
            geom_line(aes(x = date, y = daily), color = palettes$value[2]) + 
            theme_minimal() +
            labs(y = "Number of Confirmed Cases",
                 title = "Number of Confirmed Cases") +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45, margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    
    output$death_line <- renderPlotly({
        g <- ggplot(death_trace_df, aes(x = date, y = total)) +
            geom_line(color = palettes$value[1]) +
            theme_minimal() +
            labs(y = "Number of Deaths",
                 title = "Cumumlative Number of Deaths by Date") +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45, margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    
    output$daily_death_line <- renderPlotly({
        g <- ggplot(death_trace_df, aes(x = date, y = daily)) +
            geom_line(color = palettes$value[1]) +
            theme_minimal() +
            labs(y = "Number of Deaths",
                 title = "Daily Number of Deaths") +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45, margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    ## Overlay tracking - Death ##
    output$death_overlay <- renderPlotly({
        g <- ggplot(death_trace_df) +
            geom_bar(aes(x = date, y = total), stat = "identity", fill = palettes$value[1]) +
            geom_line(aes(x = date, y = daily), color = palettes$value[2]) + 
            theme_minimal() +
            labs(y = "Number of Deaths",
                 title = "Number of Deaths") +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45,margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    ## Test performed ##
    output$test_pct_line <- renderPlotly({
        g <- ggplot(test_df, aes(x = date)) +
            # geom_bar(aes(y = daily), stat = "identity", fill = palettes$value[2]) +
            geom_line(aes(y = pct_pos), color = palettes$value[1]) +
            # geom_bar(aes(y = pct_pos), stat = "identity", fill = palettes$value[2]) +
            theme_minimal() +
            labs(y = "% of Positive Results",
                 title = "Percent of Positive Test Results") +
            scale_fill_tableau() +
            scale_y_continuous(labels = scales::percent) +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45,margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g <- ggplotly(g)
    })
    
    output$test_bar <- renderPlot({
        g <- ggplot(test_df, aes(x = date)) +
            geom_bar(aes(y = daily), stat = "identity", fill = palettes$value[1]) +
            theme_minimal() +
            labs(y = "Number of Tests Performed",
                 title = "Number of Tests Performed",
                 subtitle = glue("Total Test Performed: {sum(test_df$daily)}")) +
            scale_fill_tableau() +
            scale_x_date(date_breaks= "3 days", date_minor_breaks = "1 day") +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  axis.text.x = element_text(angle=45,margin = margin(t = 20)),
                  plot.title = element_text(face = "bold"))
        g
    })
    
    output$county_per_cap_reg_line <- renderPlot({
        g <- ggplot(hist_county_df_per_capita, aes(x=POPESTIMATE2019, y = num_case, label = category)) +
            geom_point() +
            geom_text(hjust = 0, nudge_x = 10, nudge_y = 300) +
            stat_smooth(method = "lm", color = palettes$value[1]) +
            stat_regline_equation(aes(label = ..rr.label..), 
                                  formula = hist_county_df_per_capita$num_case~hist_county_df_per_capita$POPESTIMATE2019) +
            labs(x="County Population (2019)", y="Total Confirmed Cases",
                 title = "Number of Confirmed Cases vs County Population") + 
            scale_x_continuous(labels = scales::unit_format(unit = "k", scale = 1e-3)) + # in thousands
            coord_cartesian(xlim = c(0, 1700000)) + 
            theme_minimal() +
            theme(plot.title = element_text(face = "bold"))
        g
    })
    #### Map ####
    # shinyServer(function(input, output) {
    #     output$Image <- renderImage({
    #         filename <- normalizePath(file.path('www/maps',
    #                                             paste(input$route, '.png', sep='')))
    #         list(src = filename,
    #              alt = paste("Image number", input$route))
    #         
    #     }, deleteFile = FALSE)
    # })
    
    
    output$map_city <- renderImage({
        outfile = "data/map/covid19_422.png"
        list(src = outfile,
             # width = width,
             # height = height,
             alt = "City Map - April 22")
    }, deleteFile = FALSE)
    
    #### city trace plot ####
    output$city_trace_num <- renderPlot({
        top_10_cities_cnt_now <- city_df_all %>%
            filter(date == last(date)) %>%   # take latest date
            top_n(n=10, count) %>%  # top 10 count
            pull(city)
        
        # Show those top n cities
        city_df_all %>% 
            filter(city %in% top_10_cities_cnt_now) %>% 
            ggplot(aes(x=date, y = count, color = city)) +
            geom_line() +
            labs(y="Number of Confirmed Cases", 
                 # title = "Number of Confirmed COVID-19 Cases by City",
                 title = "Top 10 cities with highest number of confirmed cases",
                 subtitle = glue("Data as of {last(city_df_all$date)}")) +
            scale_color_tableau() + 
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  plot.title = element_text(face = "bold"))
        
    })
    
    output$city_trace_rate <- renderPlot({
        top_10_cities_rate_now <- city_df_all %>% 
            filter(city != "Unknown1") %>% # filter out unknown
            filter(date == last(date)) %>% # take latest date
            top_n(n=10, count) %>%  # top 10 count
            pull(city)
        
        city_df_all %>% 
            filter(city %in% top_10_cities_rate_now) %>% 
            ggplot(aes(x=date, y = rate, color = city)) +
            geom_line() +
            scale_color_tableau() + 
            labs(y="Rate per 100k population", 
                 # title = "Rate (per 100k) of Confirmed COVID-19 Cases by City ",
                 title = "Top 10 cities with highest rate",
                 subtitle = glue("Data as of {last(city_df_all$date)}")) +
            theme_minimal() +
            theme(axis.title.x = element_blank(),
                  plot.title = element_text(face = "bold"))
    })
}