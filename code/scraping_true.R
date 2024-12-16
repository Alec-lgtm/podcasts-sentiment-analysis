# Script Title: Scraping all vox articles from 2024
# Author: Alec Chen 
# Date: 2024-12-15
# Version: 0.1.0
# Purpose: Analyze sentiment of vox articles

# ---- Load Libraries ----

library(tidyverse)
library(rvest)
library(stringr)

# ---- Scraping Functions ---- 

base_url <- "https://www.vox.com/"

# Extracts the text, title, and date of an individual article
scrape_vox_article <- function(article_url, debug = FALSE) {
  Sys.sleep(0.2)
  
  # Gets article html
  article_html <- read_html(article_url)
  
  # Extracts each paragraph from the Vox article and stores each paragraph as an element in a character vector.
  article_text_vector <- article_html %>%
    html_elements("#zephr-anchor .xkp0cg1") %>%
    html_text()
  
  # Combines all paragraphs stored in 'article_text_vector' into a single string
  article_full_text <- str_c(article_text_vector, collapse = " ")
  
  # Gets article title
  article_titles <- article_html %>%
    html_elements(".xkp0cg9") %>%
    html_text()
  article_title <- article_titles[[1]]
  
  if(debug) {print(article_title)}
  
  # Gets article date
  article_date <- article_html %>%
    html_elements("time") %>%
    html_text()

  # Parses article date into a lubridate object
  final_article_date <- article_date[[1]]
  cleaned_date_string <- str_replace(final_article_date, " UTC", "")
  article_date <- parse_date_time(cleaned_date_string, orders = "b d, Y, I:M p")

  return(tibble(
    url = article_url,
    title = article_title,
    datetime = article_date,
    text = article_full_text
  ))
}

non_article_urls <- c(
  "https://www.vox.com/politics/389364/americas-ideological-fight-republican-democrat-explained",
  "https://www.vox.com/future-perfect/386449/2024-future-perfect-50-progress-ai-climate-animal-welfare-innovation",
  "https://www.vox.com/24066297/oscars-2024-guide-96th-academy-awards-what-to-watch-poor-things-oppenheimer-american-fiction",
  "https://www.vox.com/politics/367990/kamala-harris-policy-positions-issues-guide",
  "https://www.vox.com/policy/373288/the-right-explained",
  "https://www.vox.com/politics/377783/democratic-party-kamala-harris-present-future",
  "https://www.vox.com/politics/377783/democratic-party-kamala-harris-present-future", # duplicate
  "https://www.vox.com/even-better/385260/holiday-season-spending-money-pressure-hosting-guide",
  "https://www.vox.com/politics/385161/the-rebuild-newsletter-sign-up-democratic-party-liberals-progressives"
)


# Extracts the text, title, and date of every article on a given vox page
scrape_vox_page <- function(page_url, debug = FALSE) {
  Sys.sleep(0.2)
  page_html <- read_html(page_url)
  
  # Gets every article path on the vox archive page
  article_paths <- page_html %>%
    html_elements(".qcd9z1") %>%
    html_attr("href")
  
  # removes '/' from the beginning of the url string
  article_paths <- str_sub(article_paths, 2)
  
  # Creates full vox article url and removes non-articles urls + duplicates
  full_urls <- str_c(base_url, article_paths)
  full_urls <- setdiff(full_urls, non_article_urls)
  full_urls <- unique(full_urls)
  
  if(debug) {
    print(paste("page url:", page_url))
    print(paste("articles per page:", length(full_urls)))
    print("scraped titles:")
  }

  # Scrapes all articles and combines scraped elements into a dataframe
  scraped_articles <- map(full_urls, ~ scrape_vox_article(.x, debug)) %>%
    list_rbind()
  
  return(scraped_articles)
}

# Testing:
# test_df <- scrape_page("https://www.vox.com/archives/2024/11/6", TRUE)
# test_df_2 <- scrape_page("https://www.vox.com", TRUE)
# test_df_3 <- scrape_page("https://www.vox.com")

# Retrieves title, text, and date for all vox articles published in a given month
scrape_vox_month <-function(month_number, debug = FALSE) {
  Sys.sleep(0.3)
  
  # Read in page html
  page_url <- paste0(base_url, "archives/2024/", month_number, "/")
  page_html <- read_html(page_url)
  
  # Gets pagination text (ex: Previous 1 of 7 Next)
  pagination_text <- page_html %>%
    html_element(".so8yiu0") %>%
    html_text()
  
  # Extracts the number of pages in the vox archive for the given month
  page_last_number <- str_extract(pagination_text, "\\d+(?=Next)")
  
  if(debug) {
    print(paste0("month number: ", month_number))
    print(paste0("number of pages: ", page_last_number))
  }
  
  # Scrape each page in the given month's vox archive
  scraped_pages <- map(1:page_last_number, ~ scrape_vox_page(paste0(page_url, .x), debug)) %>%
    list_rbind()  # Combine all results into a single data frame
  
  return(scraped_pages)
}

# Testing:
# test_df <- scrape_vox_month(11, TRUE)
# test_df <- scrape_vox_month(2, TRUE)

# ---- Run Article Scraping ---- 
# Takes about 15-20 minutes to run

# Extract titles, url, text, and date for all vox articles in the year 2024
all_vox_articles_2024_raw <- map(1:12,scrape_vox_month, TRUE) %>% 
  list_rbind()

# Remove vox sites that are chronologies / timelines or aggregations of other articles
all_vox_articles_2024 <- all_vox_articles_2024_raw %>%
  filter(text != "")

# Verify no more NA values (should return FALSE)
any(is.na(all_vox_articles_2024))

# Filter out podcasts from articles
all_vox_articles_2024 <- all_vox_articles_2024 %>%
  filter(!str_detect(text, "Today, Explained"))

# Save cleaned dataset
saveRDS(all_vox_articles_2024, file = "2024_all_vox_articles.rds")
write.csv(all_vox_articles_2024, file = "2024_all_vox_articles.csv", row.names = FALSE)

# Save raw dataset
saveRDS(all_vox_articles_2024_raw, file = "2024_all_vox_articles_raw.rds")
write.csv(all_vox_articles_2024_raw, file = "2024_all_vox_articles_raw.csv", row.names = FALSE)
