library(syuzhet)
library(tidyverse)
library(tm)
library(ggplot2)
library(readtext)
library(tidytext)
library(stringr)

# ---- Data Cleaning ----

### Podcasts
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


### Articles
articles_text <- readRDS("../data/vox_articles/2024_all_vox_articles.rds")

articles_text_clean <- articles_text %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), doc_id = title, date = datetime)
articles_text_clean$date <- format(articles_text_clean$date, "%Y-%m-%d")
articles_text_clean$date <- as.Date(articles_text_clean$date, format = "%Y-%m-%d")

articles_text_words <- articles_text_clean %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

##680.40 words per article average


# ---- Syuzhet Sentiment Analysis ----

### Podcasts

podcasts_sentiment <- get_sentiment(podcast_transcripts_clean$text, method="syuzhet") # sentiment per document
podcasts_sentiment_mean <- mean(podcasts_sentiment)

# NRC: National Research Council Canada
podcasts_nrc_data <- get_nrc_sentiment(podcast_transcripts$text) #nrc for text as a whole

podcasts_sentiment_by_date <- podcast_transcripts_clean %>%
  mutate(sentiment = podcasts_sentiment)

podcasts_sentiment_2024 <- podcast_transcripts_clean %>%
  mutate(sentiment = podcasts_sentiment) %>%
  filter(date >= ymd("24-01-01"))


### Articles

articles_sentiment <- get_sentiment(articles_text_clean$text, method="syuzhet") # sentiment per document

articles_sentiment_mean <- mean(articles_sentiment)

articles_nrc_data <- get_nrc_sentiment(articles_text$text) #nrc for text as a whole

articles_sentiment_by_date <- articles_text_clean %>%
  mutate(sentiment = articles_sentiment)

# ---- Individual Points ----

### Podcasts

worst_sentiment_podcast <- podcasts_sentiment_by_date %>%
  filter(sentiment == min(sentiment)) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

best_podcast_sentiment <- podcasts_sentiment_by_date %>%
  filter(sentiment == max(sentiment)) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

  best_sentiment_podcast_value <- get_sentiment(best_podcast_sentiment$word, method="syuzhet")

  worst_sentiment_podcast_value <- get_sentiment(worst_sentiment_podcast$word, method="syuzhet")

### Articles

worst_sentiment_article <- articles_sentiment_by_date %>%
  filter(sentiment == min(sentiment)) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

best_sentiment_article <- articles_sentiment_by_date %>%
  filter(sentiment == max(sentiment)) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

  best_sentiment_article_value <- get_sentiment(best_sentiment_article$word, method="syuzhet")

  worst_sentiment_article_value <- get_sentiment(worst_sentiment_article$word, method="syuzhet")

# ---- Podcast Sentiment Visualizations ----

# All podcasts from 2020-2024
ggplot(podcasts_sentiment_by_date, aes(x = date, y = sentiment)) +
  geom_line() +
  geom_point() +
  labs(title = "Sentiment over Time", x = "Date", y = "Sentiment Score") +
  geom_smooth()

# Only podcasts from 2024
ggplot(podcasts_sentiment_2024, aes(x = date, y = sentiment)) +
  geom_line() +
  geom_point() +
  labs(title = "Sentiment over Time", x = "Date", y = "Sentiment Score") +
  geom_smooth()


plot(worst_sentiment_podcast_value,
  type="l",
  main="worst",
  xlab = "Narrative Time",
  ylab= "Emotional Valence")


plot(best_sentiment_podcast_value,
  type="l",
  main="best",
  xlab = "Narrative Time",
  ylab= "Emotional Valence")

# ---- Articles Sentiment Visualizations ----

ggplot(articles_sentiment_by_date, aes(x = date, y = sentiment)) +
  geom_line() +
  geom_point() +
  labs(title = "Sentiment over Time", x = "Date", y = "Sentiment Score") +
  geom_smooth()


plot(worst_sentiment_article_value, type="l", main="worst", xlab = "Narrative Time", ylab= "Emotional Valence")

plot(worst_sentiment_article_value,
  type="l",
  main="worst",
  xlab = "Narrative Time",
  ylab= "Emotional Valence")

plot(best_sentiment_article_value,
  type="l",
  main="best",
  xlab = "Narrative Time",
  ylab= "Emotional Valence")

# ---- NRC Analysis ----

podcasts_emotions <- prop.table(podcasts_nrc_data[, 1:8]) %>%
  colSums() %>%
  data.frame(Emotion = names(.), Percentage = .)

articles_emotions <- prop.table(articles_nrc_data[, 1:8]) %>%
  colSums() %>%
  data.frame(Emotion = names(.), Percentage = .)

# TODO: Change name of `emotion`
emotions <- podcasts_emotions %>%
  inner_join(articles_emotions, by = "Emotion" ) %>%
  mutate("Podcast Percentage" = Percentage.x, "Article Percentage" = Percentage.y) %>%
  select(Emotion,"Podcast Percentage", "Article Percentage") %>%
  pivot_longer(cols = c("Article Percentage", "Podcast Percentage"),
               names_to = "Media",
               values_to = "Percentage")

# Plot the side-by-side barplot
ggplot(emotions, aes(x = Emotion, y = Percentage, fill = Media)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Article NRC vs Podcast NRC",
       x = "Emotion", y = "Percentage of Sentiment", fill = "Media") +
  theme_minimal() +
  scale_fill_manual(values = c("Article Percentage" = "steelblue", "Podcast Percentage" = "darkorange"))

