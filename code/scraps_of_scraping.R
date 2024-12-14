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
    datetime <- article_date,
    text = article_full_text
  ))
}

scrape_page <- function(page_url) {
  Sys.sleep(0.3)
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
  
  scraped_urls <- character()
  
  scraped_articles <- list()
  # scraped_article <- vector("list", 15)
  
  # for (i in 1:length(urls)) {
  #   scraped_articles[[i]] <- scrape_articles(full_url[[i]])
  #   # print(full_url[[i]])
  # }
  
  # Loop through the URLs
  for (i in seq_along(urls)) {
    current_url <- full_url[[i]]
    
    print(current_url)
    
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