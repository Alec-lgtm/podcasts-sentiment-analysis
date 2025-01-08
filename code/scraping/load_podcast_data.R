library(tidyverse)
library(readtext)

podcast_file_paths <- list.files(path = "../../data/vox_podcasts/2024/", full.names = T)
podcast_transcripts <- readtext(podcast_file_paths)

# Cleans the podcast and article text so that they only contains alphanumerics and creates a date column
podcast_transcripts_clean <- podcast_transcripts %>%
  mutate(date = str_extract(doc_id, "[0-9]*_[0-9]*_[0-9]*"))

# Converts the date column into an R Date object
podcast_transcripts_clean$date <- as.Date(podcast_transcripts_clean$date,format = "%m_%d_%y")

# Add podcast title
podcast_transcripts_clean$title <- str_extract(podcast_transcripts_clean$doc_id, "\\d+_\\d+_\\d+_\\s*(.*?)\\.docx")

# Save it
write.csv(podcast_transcripts_clean, file = "../../data/vox_podcasts/podcasts_transcripts_clean.csv", row.names = FALSE)
