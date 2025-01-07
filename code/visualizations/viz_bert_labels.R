### Note: This is a rough draft

library(tidyverse)

articles_bert_labels <- read.csv("../../data/bert_labels/vox_articles_with_sentiment.csv")
podcast_bert_labels <- read.csv("../../data/bert_labels/vox_podcast_with_sentiment.csv")

articles_bert_labels$datetime <- as.POSIXct(articles_bert_labels$datetime, format = "%Y-%m-%d %H:%M:%S")
articles_bert_labels$date <- format(articles_bert_labels$datetime, "%Y-%m-%d")

# Article vs Podcast Sentiment Comparison
a1 <- ggplot(articles_bert_labels) +
  geom_bar(aes(x = sentiment, fill = sentiment)) +
  labs(title = "Sentiment Distribution in Vox News Articles",
       x = "Sentiment Category",
       y = "Number of Articles") +
  theme_minimal() +
  theme(legend.position = "none")

p1 <- ggplot(podcast_bert_labels) +
  geom_bar(aes(x = sentiment, fill = sentiment)) +
  labs(title = "Sentiment Distribution in Podcasts",
       x = "Sentiment Category",
       y = "Number of Podcasts") +
  theme_minimal()

# Confidence Score Distributions
a2 <- ggplot(articles_bert_labels) +
  geom_histogram(aes(x = score, fill = ..count..), bins = 30) +
  scale_fill_viridis_c() +
  labs(title = "Distribution of BERT Classification Confidence - Articles",
       x = "Confidence Score",
       y = "Frequency",
       subtitle = "Higher scores indicate stronger classification confidence") +
  theme_minimal()

p2 <- ggplot(podcast_bert_labels) +
  geom_histogram(aes(x = score, fill = ..count..), bins = 30) +
  scale_fill_viridis_c() +
  labs(title = "Distribution of BERT Classification Confidence - Podcasts",
       x = "Confidence Score",
       y = "Frequency",
       subtitle = "Higher scores indicate stronger classification confidence") +
  theme_minimal()

# Confidence Scores Over Time
a3 <- ggplot(articles_bert_labels, aes(x = date, y = score)) +
  geom_point(alpha = 0.5, color = "#2C3E50") +
  geom_smooth(method = "loess", color = "#E74C3C") +
  labs(title = "Article Classification Confidence Over Time",
       subtitle = "Trend analysis of BERT model confidence scores",
       x = "Publication Date",
       y = "Confidence Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p3 <- ggplot(podcast_bert_labels, aes(x = date, y = score)) +
  geom_point(alpha = 0.5, color = "#2C3E50") +
  geom_smooth(method = "loess", color = "#E74C3C") +
  labs(title = "Podcast Classification Confidence Over Time",
       subtitle = "Trend analysis of BERT model confidence scores",
       x = "Publication Date",
       y = "Confidence Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Low Confidence Score Analysis
a4 <- ggplot(article_outliers, aes(x = date, y = score)) +
  geom_point(alpha = 0.7, color = "#E67E22") +
  geom_smooth(method = "loess", color = "#2980B9", se = TRUE) +
  labs(title = "Low Confidence Classifications in Articles",
       subtitle = "Analysis of articles with confidence scores below 0.95",
       x = "Publication Date",
       y = "Confidence Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 1),
        axis.title.x = element_text(margin = margin(t = 10)),
        panel.grid.minor = element_blank())

p4 <- ggplot(article_outliers, aes(x = date, y = score)) +
  geom_point(alpha = 0.7, color = "#E67E22") +
  geom_smooth(method = "loess", color = "#2980B9", se = TRUE) +
  labs(title = "Low Confidence Classifications in Podcasts",
       subtitle = "Analysis of podcasts with confidence scores below 0.95",
       x = "Publication Date",
       y = "Confidence Score") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 1),
        axis.title.x = element_text(margin = margin(t = 10)),
        panel.grid.minor = element_blank())
