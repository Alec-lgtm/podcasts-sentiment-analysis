### Note: This is a rough draft

library(tidyverse)

articles_bert_labels <- read.csv("../../data/bert_labels/vox_articles_with_sentiment.csv")

articles_bert_labels_prob <- read.csv("../../data/bert_labels/vox_articles_raw_probs.csv")

articles_bert_labels$datetime <- as.POSIXct(articles_bert_labels$datetime, format = "%Y-%m-%d %H:%M:%S")

articles_bert_labels$date <- format(articles_bert_labels$datetime, "%Y-%m-%d")

# How many articles are positive vs negative
p1 <- ggplot(articles_bert_labels) +
  geom_bar(aes(x = sentiment)) +
  theme_classic()

# Distribution of how confident we are in the scores
p2 <- ggplot(articles_bert_labels) +
  geom_histogram(aes(x = score)) +
  theme_classic()

# How do confidence rankings change over time
p3 <- ggplot(articles_bert_labels, aes(x = date, y = score)) +
  geom_point() +
  labs(title = "Confidence Scores over time", x = "Date", y = "Confidence Score") +
  geom_smooth()

# Some scores have much less confidence than others
article_outliers <- articles_bert_labels %>%
  filter(score < 0.95) %>%
  mutate(date = format(as.Date(date), "%m-%d")) %>%
  arrange(desc(score))

p4 <- ggplot(article_outliers, aes(x = date, y = score)) +
  geom_point() +
  labs(title = "Confidence Scores over time", x = "Date", y = "Confidence Score") +
  geom_smooth() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust = 1),
        axis.title.x = element_text(margin = margin(t = 10)))

# prob
p5 <- ggplot(articles_bert_labels_prob) +
  geom_histogram(aes(x = pos_score)) +
  theme_classic()

