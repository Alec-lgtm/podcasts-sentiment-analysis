library(tidyverse)
library(rvest)
library(stringr)

base_url <- "https://www.vox.com/"

# scrapes all the article text in a vox article
scrape_articles <- function(article_url) {
  Sys.sleep(0.5)
  # print(read_html(article_url))

  # better to remove this from the list, it's more computationally efficient... ie full_url
  if(article_url == "https://www.vox.com/politics/389364/americas-ideological-fight-republican-democrat-explained" |
     article_url == "https://www.vox.com/future-perfect/386449/2024-future-perfect-50-progress-ai-climate-animal-welfare-innovation")
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

  # return(article_titles)

  # print(article_titles)

  article_title <- article_titles[[1]]

  print(article_title)

  article_date <- article_html %>%
    html_elements("time") %>%
    html_text()

  # print(article_title)
  final_article_date <- article_date[[1]]
  # final_article_date <- article_date[[1]]

  return(tibble(
    url = article_url,
    title = article_title,
    date = final_article_date,
    text = article_full_text
  ))
}

test <- scrape_articles("https://www.vox.com/policy/390309/maha-rfk-make-america-healthy-again-slippery")

scrape_articles("https://www.vox.com/politics/390953/the-onion-infowars-alex-jones")
test <- scrape_articles("https://www.vox.com/politics/390108/working-class-definition-voters-2024")

# Goes through vox/archives/# to and scrapes all the page
scrape_page <- function(page_number) {
  Sys.sleep(0.3)
  page_url <- paste0(base_url, "archives/", page_number)
  # print(page_url)
  page <- read_html(page_url)

  articles_titles <- page %>%
    html_elements(".qcd9z1") %>%
    html_text()

  urls <- page %>%
    html_elements(".qcd9z1") %>%
    html_attr("href")

  urls <- str_sub(urls, 2)
  # browser()
  print(length(urls))

  full_url <- str_c(base_url, urls)

  scraped_articles <- list()
  # scraped_article <- vector("list", 15)

  for (i in 1:length(urls)) {
    scraped_articles[[i]] <- scrape_articles(full_url[[i]])
    # print(full_url[[i]])
  }

  return(scraped_articles)
}
# onepage <- scrape_page(1)
# secondpage <- scrape_page(6)

# Run through 15 pages of the archive
scraped_pages <- list()
for (i in 1:5) {
  # print(scrape_page(i))
  scraped_pages[[i]] <- scrape_page(i)
}

# Vim motions
# viw visual select the inner word
# ciw change the inner word
# yiw yank the inner word
# vi{ gets the inner of the {}
# dt{ deletes everything to the {

# Fix page 6

# saveRDS(scraped_pages, file = "scraped_pages_with_date_title_duplicates.rds")

