# Description: Run scraping code
# Author: Alec Chen
# Date: 2024-12-15
# Version: 0.0.1
# Purpose: Analyze sentiment of vox articles

# Load libraries and functions
source('scraping_functions.R')

# ---- Data Cleaning ----

# Filter Vox staff articles
# Note: Vox staff articles aren't exactly articles, they're more aggregations of other articles which is why we filter them
vox_staff_articles <- scrape_vox_archive(6,"authors/vox-staff/archives/", url_only = TRUE, debug_page = TRUE, debug_article = TRUE)

excluded_urls = c(non_article_urls,vox_staff_articles$url)

test_df <- scrape_vox_month(month_number = 11, filter_urls = excluded_urls, debug_month = T, debug_page = T, debug_article = T)

# ---- Article Scraping ----
# Takes about 10-15 minutes to run
# Logs are stored in scraping_log.txt

# Extract titles, url, text, and date for all vox articles in the year 2024
all_vox_articles_2024_raw <- map(1:12,scrape_vox_month, filter_urls = excluded_urls, debug_month = TRUE, debug_page = TRUE, debug_article = FALSE) %>%
  list_rbind()

# Remove vox sites that are chronologies / timelines or aggregations of other articles
all_vox_articles_2024 <- all_vox_articles_2024_raw %>%
  filter(text != "")

# Verify no more NA values (should return FALSE)
any(is.na(all_vox_articles_2024))

# Filter out podcasts from articles
all_vox_articles_2024 <- all_vox_articles_2024 %>%
  filter(!str_detect(text, "Today, Explained"))

# ---- Check this ----

# Go through these
df <- all_vox_articles_2024 %>%
  filter(str_detect(text, "Explain It to Me"))

# works
df1 <- all_vox_articles_2024 %>%
  filter(str_detect(text, "The Gray Area"))

# just remove the front of the url
df3 <- all_vox_articles_2024 %>%
  filter(str_detect(text, "Unexplainable"))

# Also remove urls of vox videos

# Instead of doing it by article length --> do it by its been written by a vox staff or not
all_vox_articles_2024  %>%
  # Count words in each article using str_count and a word pattern
  mutate(article_length = str_count(text, "\\S+")) %>%
  # Summarize to get the average length
  summarize(average_length = mean(article_length, na.rm = TRUE))

# ---- Finish this ----

# Save cleaned dataset
saveRDS(all_vox_articles_2024, file = "../../data/vox_articles/2024_all_vox_articles.rds")
write.csv(all_vox_articles_2024, file = "../../data/vox_articles/2024_all_vox_articles.csv", row.names = FALSE)

# Save raw dataset
saveRDS(all_vox_articles_2024_raw, file = "../../data/vox_articles/2024_all_vox_articles_raw.rds")
write.csv(all_vox_articles_2024_raw, file = "../../data/vox_articles/2024_all_vox_articles_raw.csv", row.names = FALSE)

