library(syuzhet)
library(tidyverse)
library(tm)
library(ggplot2)
library(readtext)
library(tidytext)
library(stringr)
library(zoo)

# Load article and podcast data
podcast_file_paths <- list.files(path = "../../data/vox_podcasts/", full.names = T, recursive = T)
podcast_transcripts <- readtext(podcast_file_paths)
articles_text <- readRDS("../../data/vox_articles/2024_all_vox_articles.rds")

# Cleans the podcast and article text so that they only contains alphanumerics and creates a date column
podcast_transcripts_clean <- podcast_transcripts %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), date = str_extract(doc_id, "[0-9]*_[0-9]*_[0-9]*"))
articles_text_clean <- articles_text %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), doc_id = title, date = datetime)

# Converts the date column into an R Date object
podcast_transcripts_clean$date <- as.Date(podcast_transcripts_clean$date,format = "%m_%d_%y")
articles_text_clean$date <- format(articles_text_clean$date, "%Y-%m-%d")
articles_text_clean$date <- as.Date(articles_text_clean$date, format = "%Y-%m-%d")

# Add podcast title
podcast_transcripts_clean$title <- str_extract(podcast_transcripts_clean$doc_id, "\\d+_\\d+_\\d+_\\s*(.*?)\\.docx")

# Save cleaned podcast_transcript
write.csv(podcast_transcripts_clean, file = "../../data/vox_podcasts/podcasts_transcripts_clean.csv", row.names = FALSE)

# Splits the cleaned text into individual words so that we can run an sentiment analysis on it
podcast_transcripts_words <- podcast_transcripts_clean %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") # 1562.74 words per podcast average
articles_text_words <- articles_text_clean %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") #680.40 words per article average

### Syuzhet Built-in analysis

# Calculates the sentiment score for each document in the podcasts and articles
podcasts_sentiment <- get_sentiment(podcast_transcripts_clean$text, method="syuzhet") # sentiment per document
articles_sentiment <- get_sentiment(articles_text_clean$text, method="syuzhet") # sentiment per document

# Gets mean sentiment score
podcasts_sentiment_mean <- mean(podcasts_sentiment) # get mean sentiment score
articles_sentiment_mean <- mean(articles_sentiment)

# Calculates sentiment score on the National Research Council Canada metrics
podcasts_nrc_data <- get_nrc_sentiment(podcast_transcripts$text)
articles_nrc_data <- get_nrc_sentiment(articles_text$text)

# Add sentiment score to original podcast and article dataset
podcasts_sentiment_by_date <- podcast_transcripts_clean %>%
  mutate(sentiment = podcasts_sentiment)
articles_sentiment_by_date <- articles_text_clean %>%
  mutate(sentiment = articles_sentiment)

# Only get podcast sentiment scores from the year 2024
podcasts_sentiment_2024 <- podcast_transcripts_clean %>%
  mutate(sentiment = podcasts_sentiment) %>%
  filter(date >= ymd("24-01-01"))

### Get best and worst sentiment podcast
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

### Get best and worst sentiment article

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

# All podcasts from 2020-2024
podcast_2020_2024_viz <- ggplot(podcasts_sentiment_by_date, aes(x = date, y = sentiment)) +
  geom_line() +
  geom_point() +
  labs(title = "Sentiment over Time", x = "Date", y = "Sentiment Score") +
  geom_smooth()

# Only podcasts from 2024
podcast_2024_viz <- ggplot(podcasts_sentiment_2024, aes(x = date, y = sentiment)) +
  geom_line() +
  geom_point() +
  labs(title = "Podcast sentiment in the year 2024", x = "Date", y = "Sentiment Score") +
  geom_smooth()

# All articles 2024
articles_2024_viz <- ggplot(articles_sentiment_by_date, aes(x = date, y = sentiment)) +
  geom_line() +
  geom_point() +
  labs(title = "Article sentiment in the year 2024", x = "Date", y = "Sentiment Score") +
  geom_smooth()

# Sentiment over time in worst podcast
plot(worst_sentiment_podcast_value,
     type="l",
     main="worst",
     xlab = "How word sentiment changes in the lowest ranking sentiment podcast",
     ylab= "Emotional Valence")

# Sentiment over time in best podcast
plot(best_sentiment_podcast_value,
     type="l",
     main="best",
     xlab = "How word sentiment changes in the best ranking sentiment podcast",
     ylab= "Emotional Valence")

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

# Function to visualize podcast sentiment
visualize_podcast_sentiment <- function(sentiment_vector, window_size = 20,name) {
  # Create a data frame with the raw sentiment data
  df <- data.frame(
    time = 1:length(sentiment_vector),
    sentiment = sentiment_vector
  )
  
  # Calculate rolling mean, handling zero values appropriately
  df$smoothed_sentiment <- rollmean(sentiment_vector, 
                                    k = window_size, 
                                    fill = NA, 
                                    align = "center")
  
  # Create main plot with both raw and smoothed data
  p <- ggplot(df, aes(x = time)) +
    # Add horizontal line at y = 0
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50", alpha = 0.5) +
    # Raw sentiment points
    geom_point(aes(y = sentiment), 
               alpha = 0.3, 
               size = 1,
               color = "gray50") +
    # Smoothed line
    geom_line(aes(y = smoothed_sentiment),
              color = "#2563eb",
              size = 1) +
    # Add theme and labels
    theme_classic() +
    labs(title = paste(name,
                       window_size, "-word Moving Average", sep=""),
         x = "Narrative Time",
         y = "Sentiment Score") +
    # Set fixed y-axis limits based on your data range
    scale_y_continuous(limits = c(-1, 1),
                       breaks = seq(-1, 1, 0.25)) +
    # Customize theme elements
    theme(
      plot.title = element_text(hjust = 0.5, size = 14),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "gray50")
    )
  
  return(p)
}

# Plot best and worst article and podcast
article_worst <- visualize_podcast_sentiment(worst_sentiment_article_value,  window_size = 10, "Article Sentiment Analysis\n")
podcast_worst <- visualize_podcast_sentiment(worst_sentiment_podcast_value, window_size = 10, "Podcast Sentiment Analysis\n")
article_best <- visualize_podcast_sentiment(best_sentiment_article_value, window_size = 10, "Article Sentiment Analysis\n")
podcast_best <- visualize_podcast_sentiment(best_sentiment_podcast_value, window_size = 10, "Podcast Sentiment Analysis\n")

# Save plots
ggsave("../../figures/worst_article_sentiment_rolling_average_10.png", article_worst, bg = "white", width = 10, height = 6)
ggsave("../../figures/worst_podcast_sentiment_rolling_average_10.png", podcast_worst, bg = "white", width = 10, height = 6)
ggsave("../../figures/best_article_sentiment_rolling_average_10.png", article_best, bg = "white", width = 10, height = 6)
ggsave("../../figures/best_podcast_sentiment_rolling_average_10.png", podcast_best, bg = "white", width = 10, height = 6)

# Gets the 8 emotions the podcasts and articles will be ranked by
podcasts_nrc_emotions <- prop.table(podcasts_nrc_data[, 1:8]) %>%
  colSums() %>%
  data.frame(Emotion = names(.), Percentage = .)
articles_nrc_emotions <- prop.table(articles_nrc_data[, 1:8]) %>%
  colSums() %>%
  data.frame(Emotion = names(.), Percentage = .)

# Joins the podcast and article data
podcast_articles_nrc_emotion_levels <- podcasts_nrc_emotions %>%
  inner_join(articles_nrc_emotions, by = "Emotion" ) %>%
  mutate("Podcast Percentage" = Percentage.x, "Article Percentage" = Percentage.y) %>%
  select(Emotion,"Podcast Percentage", "Article Percentage") %>%
  pivot_longer(cols = c("Article Percentage", "Podcast Percentage"),
               names_to = "Media",
               values_to = "Percentage")

# Plots the percentage of words associated with that emotion.
nrc_emotional_levels_viz <- ggplot(podcast_articles_nrc_emotion_levels, aes(x = Emotion, y = Percentage, fill = Media)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Article Emotion levels vs Podcast Emotion levels",
       x = "Emotion", y = "Percentage of Sentiment", fill = "Media", caption = "Emotion levels from NRC Database") +
  theme_minimal() +
  scale_fill_manual(values = c("Article Percentage" = "steelblue", "Podcast Percentage" = "darkorange"))

save.image(file = "../../data/visualizations_worspace.RData")
