# Description: Run scraping code
# Author: Alec Chen
# Date: 2024-12-15
# Version: 0.0.1
# Purpose: Analyze sentiment of vox articles

# Load libraries and functions
source('scraping_functions.R')

# ---- Article Scraping ----
# Filter Vox staff articles
# Note: Vox staff articles aren't exactly articles, they're more aggregations of other articles which is why we filter them
vox_staff_articles <- scrape_vox_archive(6,"authors/vox-staff/archives/", url_only = TRUE, debug_page = TRUE, debug_article = TRUE)

excluded_urls = c(non_article_urls,vox_staff_articles$url)

test_df <- scrape_vox_month(month_number = 11, filter_urls = excluded_urls, debug_month = T, debug_page = T, debug_article = T)
# Takes about 10-15 minutes to run
# Logs are stored in scraping_log.txt

# Extract titles, url, text, and date for all vox articles in the year 2024
all_vox_articles_2024_raw <- map(1:12,scrape_vox_month, filter_urls = excluded_urls, debug_month = TRUE, debug_page = TRUE, debug_article = FALSE) %>%
  list_rbind()


# ---- Data Cleaning ----

# Remove vox sites that are chronologies / timelines or aggregations of other articles
all_vox_articles_2024 <- all_vox_articles_2024_raw %>%
  filter(text != "")

# Verify no more NA values (should return FALSE)
any(is.na(all_vox_articles_2024))

# Remove videos and articles about podcasts
remove_base_urls <- c(
    "https://www.vox.com/videos/",
    "https://www.vox.com/today-explained-podcast/",
    "https://www.vox.com/explain-it-to-me/",
    "https://www.vox.com/the-gray-area/",
    "https://www.vox.com/unexplainable/"
)

# Remove videos and articles about podcasts
all_vox_articles_2024 <- all_vox_articles_2024 %>%
  filter(!map_lgl(url, ~ any(startsWith(.x, remove_base_urls))))

# Save cleaned dataset
saveRDS(all_vox_articles_2024, file = "../../data/vox_articles/2024_all_vox_articles.rds")
write.csv(all_vox_articles_2024, file = "../../data/vox_articles/2024_all_vox_articles.csv", row.names = FALSE)

# Save raw dataset
saveRDS(all_vox_articles_2024_raw, file = "../../data/vox_articles/2024_all_vox_articles_raw.rds")
write.csv(all_vox_articles_2024_raw, file = "../../data/vox_articles/2024_all_vox_articles_raw.csv", row.names = FALSE)

