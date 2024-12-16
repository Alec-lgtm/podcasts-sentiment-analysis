library(tidyverse)
library(rvest)
library(stringr)

base_url <- "https://www.vox.com/"

# Function to scrape the text, title, and date of each individual article
scrape_articles <- function(article_url) {
  Sys.sleep(0.2)
  # print(read_html(article_url))
  
  # better to remove this from the list, it's more computationally efficient... ie full_url
  if(article_url == "https://www.vox.com/politics/389364/americas-ideological-fight-republican-democrat-explained" |
     article_url == "https://www.vox.com/future-perfect/386449/2024-future-perfect-50-progress-ai-climate-animal-welfare-innovation" |
     article_url == "https://www.vox.com/24066297/oscars-2024-guide-96th-academy-awards-what-to-watch-poor-things-oppenheimer-american-fiction" |
     article_url == "https://www.vox.com/politics/367990/kamala-harris-policy-positions-issues-guide" |
     article_url == "https://www.vox.com/policy/373288/the-right-explained" |
     article_url == "https://www.vox.com/politics/377783/democratic-party-kamala-harris-present-future" |
     article_url == "https://www.vox.com/politics/377783/democratic-party-kamala-harris-present-future" |
     article_url == "https://www.vox.com/even-better/385260/holiday-season-spending-money-pressure-hosting-guide" |
     article_url == "https://www.vox.com/politics/385161/the-rebuild-newsletter-sign-up-democratic-party-liberals-progressives")
    return()
  
  article_html <- read_html(article_url)
  
  article_text_vector <- article_html %>%
    html_elements("#zephr-anchor .xkp0cg1") %>%
    html_text()
  
  # browser()
  
  article_full_text <- paste(article_text_vector, collapse = " ")
  # print(article_full_text)
  
  article_titles <- article_html %>%
    html_elements(".xkp0cg9") %>%
    html_text()
  
  article_title <- article_titles[[1]]
  
  print(article_title) # debugging
  
  article_date <- article_html %>%
    html_elements("time") %>%
    html_text()
  
  # print(article_title)
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
scrape_page <- function(page_url) {
  Sys.sleep(0.2)
  page <- read_html(page_url)
  
  print(page_url)
  
  articles_titles <- page %>%
    html_elements(".qcd9z1") %>%
    html_text()
  
  urls <- page %>%
    html_elements(".qcd9z1") %>%
    html_attr("href")
  
  print(urls)
  
  urls <- str_sub(urls, 2)
  # browser()
  
  full_url <- str_c(base_url, urls)
  print(length(full_url))
  
  full_url <- setdiff(full_url, non_article_urls)
  print(length(full_url))
  
  # browser()
  
  scraped_urls <- character()
  scraped_articles <- list()
  
  # Loop through the URLs
  for (i in seq_along(urls)) {
    current_url <- full_url[[i]]
    
    # print(current_url)
    
    # Check if the URL has already been scraped
    if (!(current_url %in% scraped_urls)) {
      # Scrape the article and store it
      scraped_articles[[length(scraped_articles) + 1]] <- scrape_articles(current_url)
      
      # Add the URL to the list of scraped URLs
      scraped_urls <- c(scraped_urls, current_url)
    } else {
      message("Already scraped: ", current_url)
    }
  }
  
  return(scraped_articles)
}

# test <- scrape_page("https://www.vox.com/archives/2024/11/6")

scrape_month <-function(month_number) {
  #Sys.sleep(0.3)
  print(paste0("month number: ", month_number))
  page_url <- paste0(base_url, "archives/2024/", month_number, "/")
  page <- read_html(page_url)
  
  pagination_text <- page %>%
    html_element(".so8yiu0") %>%
    html_text()
  
  page_last_number <- str_extract(pagination_text, "\\d+(?=Next)")
  
  scraped_pages <- list()
  
  # for (i in 1:page_last_number) {
  #   scraped_pages[[i]] <- scrape_page(page_url)
  # }
  
  # scraped_pages <- map(1:page_last_number, ~ scrape_page(page_url)) %>%
  #   list_rbind()
  
  scraped_pages <- map(1:page_last_number, ~ scrape_page(paste0(page_url, .x))) %>%
    flatten() %>%
    list_rbind()
  
  return(scraped_pages)
}

