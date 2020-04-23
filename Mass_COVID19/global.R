# Global variables
library(ggthemes)
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

# Pre-processed numbers
num_case_trace_df <- readRDS("data/hist/num_case_trace_df.rds")
death_trace_df <- readRDS("data/hist/death_trace_df.rds")
hist_county_df <- readRDS("data/hist/hist_county_df.rds")

# Census
census_county_df <- read_csv("data/census/co-est2019-alldata.csv") %>% 
  filter(STNAME == "Massachusetts") %>% 
  filter(CTYNAME != "Massachusetts") %>% 
  mutate(CTYNAME = gsub(" County", "", CTYNAME))

# County per capita
hist_county_df_per_capita <- hist_county_df %>% 
  # Update to datetime object
  mutate(date = mdy(date)) %>% 
  arrange(date) %>% 
  filter(date == last(date)) %>% # last date of historical confirmed cases April 19
  filter(category != "Unknown") %>% # remove unknown
  left_join(census_county_df %>% select(CTYNAME, POPESTIMATE2019), by = c("category" = "CTYNAME"))
