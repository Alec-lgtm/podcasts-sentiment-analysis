# Description: Run scraping code
# Author: Alec Chen
# Date: 2024-12-15
# Version: 0.0.1
# Purpose: Analyze sentiment of vox articles


# ---- Article Scraping ----
# Takes about 10-15 minutes to run
# Logs are stored in scraping_log.txt

# Load libraries and functions
source('scraping_functions.R')

# Extract titles, url, text, and date for all vox articles in the year 2024
all_vox_articles_2024_raw <- map(1:12,scrape_vox_month, debug_month = TRUE, debug_page = TRUE, debug_article = FALSE) %>%
  list_rbind()

# Remove vox sites that are chronologies / timelines or aggregations of other articles
all_vox_articles_2024 <- all_vox_articles_2024_raw %>%
  filter(text != "")

# Verify no more NA values (should return FALSE)
any(is.na(all_vox_articles_2024))

# Filter out podcasts from articles
all_vox_articles_2024 <- all_vox_articles_2024 %>%
  filter(!str_detect(text, "Today, Explained"))

# Save cleaned dataset
saveRDS(all_vox_articles_2024, file = "../../data/vox_articles/2024_all_vox_articles.rds")
write.csv(all_vox_articles_2024, file = "../../data/vox_articles/2024_all_vox_articles.csv", row.names = FALSE)

# Save raw dataset
saveRDS(all_vox_articles_2024_raw, file = "../../data/vox_articles/2024_all_vox_articles_raw.rds")
write.csv(all_vox_articles_2024_raw, file = "../../data/vox_articles/2024_all_vox_articles_raw.csv", row.names = FALSE)

