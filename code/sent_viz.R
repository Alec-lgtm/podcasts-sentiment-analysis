library(syuzhet)
library(tidyverse)
library(tm)
library(ggplot2)
library(readtext)
library(tidytext)
library(stringr)

# ---- Data Cleaning ----

#### Podcasts
podcast_file_paths <- list.files(path = "../data/vox_podcasts", full.names = T, recursive = T)
podcast_transcripts <- readtext(podcast_file_paths)

# cleans the transcript so that it only contains alphanumerics and creates a date column
podcast_transcripts_clean <- podcast_transcripts %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), date = str_extract(doc_id, "[0-9]*_[0-9]*_[0-9]*"))

# Converts the date column into a Date object
podcast_transcripts_clean$date <- as.Date(podcast_transcripts_clean$date,format = "%m_%d_%y")

# Add podcast title
podcast_transcripts_clean$title <- str_extract(podcast_transcripts_clean$doc_id, "\\d+_\\d+_\\d+_\\s*(.*?)\\.docx")

#splits the cleaned transcript to individual words so that we can run an sentiment analysis on it
podcast_transcripts_words <- podcast_transcripts_clean %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")
##1562.74 words per podcast average


#### Articles
vox_articles_text <- readRDS("../data/vox_articles/2024_all_vox_articles.rds")

vox_articles_text_clean <- vox_articles_text %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), doc_id = title, date = datetime)
vox_articles_text_clean$date <- format(vox_articles_text_clean$date, "%Y-%m-%d")
vox_articles_text_clean$date <- as.Date(vox_articles_text_clean$date, format = "%Y-%m-%d")

vox_articles_text_words <- vox_articles_text_clean %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

##680.40 words per article average


# ---- Syuzhet Sentiment Analysis

#### Podcasts

podcasts_sentiment <- get_sentiment(podcast_transcripts_clean$text, method="syuzhet") # sentiment per document
podcasts_sentiment_mean <- mean(podcasts_sentiment)

# NRC: National Research Council Canada
podcasts_nrc_data <- get_nrc_sentiment(podcast_transcripts$text) #nrc for text as a whole

podcasts_sentiment_by_date <- podcast_transcripts_clean %>%
  mutate(sentiment = podcasts_sentiment)

podcasts_sentiment_2024 <- podcast_transcripts_clean %>%
  mutate(sentiment = podcasts_sentiment) %>%
  filter(date >= ymd("24-01-01"))


#### Articles

articles_sentiment <- get_sentiment(vox_articles_text_clean$text, method="syuzhet") # sentiment per document

articles_sentiment_mean <- mean(articles_sentiment)

articles_nrc_data <- get_nrc_sentiment(vox_articles_text$text) #nrc for text as a whole

articles_sentiment_by_date <- vox_articles_text_clean %>%
  mutate(sentiment = articles_sentiment)



