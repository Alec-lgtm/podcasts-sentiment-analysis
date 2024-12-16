library(tidyverse)
library(rvest)
library(stringr)

base_url <- "https://www.vox.com/"

# Function to scrape the text, title, and date of each individual article
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


# 'Gets every article on each page of archived vox articles
# 'Calls scrape_articles() on each article
scrape_page <- function(page_url, debug = FALSE) {
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
  full_urls <- setdiff(full_url, non_article_urls)
  full_urls <- unique(full_urls)
  
  if(debug) {
    print(paste("page url:", page_url))
    print(paste("articles per page:", length(full_url)))
    print("scraped titles:")
  }

  scraped_articles <- map(full_urls, ~ scrape_vox_article(.x, debug)) %>%
    list_rbind()
  
  print(class(scraped_articles))
                          
  return(scraped_articles)
}

# Testing:
# test_df <- scrape_page("https://www.vox.com/archives/2024/11/6", TRUE)
# test_df_2 <- scrape_page("https://www.vox.com", TRUE)
test_df_3 <- scrape_page("https://www.vox.com")


# Retrieves all articles published in a given month
scrape_month <-function(month_number, debug = FALSE) {
  Sys.sleep(0.3)
  print(paste0("month number: ", month_number))
  page_url <- paste0(base_url, "archives/2024/", month_number, "/")
  page_html <- read_html(page_url)
  
  pagination_text <- page_html %>%
    html_element(".so8yiu0") %>%
    html_text()
  
  print(pagination_text)
  
  # Extracts the number of pages each month has
  page_last_number <- str_extract(pagination_text, "\\d+(?=Next)")
  
  # Scrape each page in the month's archive
  scraped_pages <- list()
  scraped_pages <- map(1:page_last_number, ~ scrape_page(paste0(page_url, .x))) %>%
    flatten() %>% # Flatten the list of results
    list_rbind()  # Combine all results into a single data frame
  
  return(scraped_pages)
}

# Testing:
# test_df <- scrape_page("https://www.vox.com/archives/2024/11/", TRUE)
