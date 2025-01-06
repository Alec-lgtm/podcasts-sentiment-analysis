# Description: Functions to scrape vox articles
# Author: Alec Chen
# Date: 2024-12-15
# Version: 0.1.0
# Purpose: Analyze sentiment of vox articles

# ---- Load Libraries ----

library(tidyverse)
library(rvest)
library(stringr)
library(logging)

# Sets up logging for debugging
basicConfig()
addHandler(writeToFile, file = "scraping_log.txt")

# Manually removed article urls
non_article_urls <- c(
  "https://www.vox.com/future-perfect/386449/2024-future-perfect-50-progress-ai-climate-animal-welfare-innovation",
  "https://www.vox.com/24066297/oscars-2024-guide-96th-academy-awards-what-to-watch-poor-things-oppenheimer-american-fiction"
)

# ---- Scraping Functions ----

base_url <- "https://www.vox.com/"

# Extracts the text, title, and date of an individual article
scrape_vox_article <- function(article_url, url_only = FALSE, debug_article = FALSE) {
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

  if(debug_article) {loginfo(article_title)}
  
  # Gets article author
  article_author <- article_html %>%
    html_elements("._15r56j10 p") %>%
    html_text()

  if(!url_only) {
    # Gets article date
    article_date <- article_html %>%
      html_elements("time") %>%
      html_text()
    
    # Parses article date into a lubridate object
    final_article_date <- article_date[[1]]
    cleaned_date_string <- str_replace(final_article_date, " UTC", "")
    article_date <- parse_date_time(cleaned_date_string, orders = "b d, Y, I:M p")
  }
  

  if(url_only) {
    return(tibble(url = article_url))
  }
  else {
    return(tibble(
      url = article_url,
      title = article_title,
  	  author = article_author,
      datetime = article_date,
      text = article_full_text
    ))
  }
}

# Testing
# scrape_vox_article("https://www.vox.com/future-perfect/386449/2024-future-perfect-50-progress-ai-climate-animal-welfare-innovation", debug_article = TRUE)
# scrape_vox_article("https://www.vox.com/life/382324/gift-giving-perfectionism-stress-anxiety-expectations", debug_article = TRUE)

# Extracts the text, title, and date of every article on a given vox page
scrape_vox_page <- function(page_url, url_only = FALSE, filter_urls = NA, debug_page = FALSE, debug_article = FALSE) {
  Sys.sleep(0.2)
  page_html <- read_html(page_url)

  # Gets every article path on the vox archive page
  article_paths <- page_html %>%
    html_elements(".qcd9z1") %>%
    html_attr("href")

  # removes '/' from the beginning of the url string
  article_paths <- str_sub(article_paths, 2)

  # Creates full vox article url
  full_urls <- str_c(base_url, article_paths)
  
  # Removes non-articles urls + duplicates
  if(missing(filter_urls)) {} else {full_urls <- setdiff(full_urls, filter_urls)}
  full_urls <- unique(full_urls)

  if(debug_page) {
    loginfo(paste("Page Url:", page_url))
    loginfo(paste("Number of Articles on this Page:", length(full_urls)))
  }
  if(debug_article) {loginfo("**Scraped Titles Below:**")}

  # Scrapes all articles and combines scraped elements into a dataframe
  scraped_articles <- map(full_urls, ~ scrape_vox_article(.x, url_only, debug_article)) %>%
    list_rbind()

  return(scraped_articles)
}

# Testing:
# test_df <- scrape_vox_page("https://www.vox.com/archives/2024/11/6", url_only = TRUE, debug_page = TRUE, debug_article = TRUE)
# test_df_2 <- scrape_vox_page("https://www.vox.com", TRUE)
# test_df_3 <- scrape_vox_page("https://www.vox.com")

# Retrieves title, text, and date for all vox articles published in a given month
scrape_vox_month <-function(month_number, url_only = FALSE, filter_urls = NA, debug_month = FALSE, debug_page = FALSE, debug_article = FALSE) {
  Sys.sleep(0.3)

  # Get page html
  page_url <- paste0(base_url, "archives/2024/", month_number, "/")
  page_html <- read_html(page_url)
  
  # Gets pagination text (ex: Previous 1 of 7 Next)
  pagination_text <- page_html %>%
    html_element(".so8yiu0") %>%
    html_text()
  
  # Extracts the number of pages in the vox archive for the given month
  page_last_number <- str_extract(pagination_text, "\\d+(?=Next)")

  if(debug_month) {
    loginfo(paste0("month number: ", month_number))
    loginfo(paste0("number of pages: ", page_last_number))
  }

  # Scrape each page in the given month's vox archive
  scraped_pages <- map(1:page_last_number, ~ scrape_vox_page(paste0(page_url, .x), url_only, filter_urls, debug_page, debug_article)) %>%
    list_rbind()  # Combine all results into a single data frame

  return(scraped_pages)
}

# Testing:
# test_df <- scrape_vox_month(month_number = 11, debug_month = T, debug_page = T, debug_article = T)

# More general version of scrape_vox_month, works for all vox archives 
# Note: the url path does not include the page ie "authors/vox-staff/archives/" not "authors/vox-staff/archives/6"
scrape_vox_archive <-function(last_page = NA, url_path = NA, url_only = FALSE, filter_urls = NA, debug_page = FALSE, debug_article = FALSE) {
  Sys.sleep(0.3)
  
  # Get page html
  page_url <- paste0(base_url, url_path)
  page_html <- read_html(page_url)
  
  # Gets pagination text (ex: Previous 1 of 7 Next)
  pagination_text <- page_html %>%
    html_element(".so8yiu0") %>%
    html_text()
  
  if(missing(last_page)) {
    # Extracts the number of pages in the vox archive for the given month
    last_page <- str_extract(pagination_text, "\\d+(?=Next)")
  }
  
  if(debug_page) {
    loginfo(paste0("number of pages: ", last_page))
  }
  
  # Scrape each page in the given month's vox archive
  scraped_pages <- map(1:last_page, ~ scrape_vox_page(paste0(page_url, .x), url_only, filter_urls, debug_page, debug_article)) %>%
    list_rbind()  # Combine all results into a single data frame
  
  return(scraped_pages)
}

# Testing
# test_df <- scrape_vox_archive(6,"authors/vox-staff/archives/",TRUE, TRUE, TRUE)

# Testing:
# test_df <- scrape_vox_month(11, TRUE)
# test_df <- scrape_vox_month(2, TRUE)

