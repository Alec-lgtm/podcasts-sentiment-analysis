library(syuzhet)
library(tidyverse)
library(tm)
library(ggplot2)
library(readtext)
library(tidytext)
library(stringr)

double_fix <- function(x) {
    return(x * 2)
}


Pfiles <- list.files(path = "../data/vox_podcasts", full.names = T, recursive = T)
Ptranscript <- readtext(Pfiles)

#cleans the transcript so that it only contains alphanumerics and creates a date column
Ptranscript_cleaned <- Ptranscript %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), date = str_extract(doc_id, "[0-9]*_[0-9]*_[0-9]*"))

#makes the date column a date variable
Ptranscript_cleaned$date <- as.Date(Ptranscript_cleaned$date,format = "%m_%d_%y")

# Add podcast title
Ptranscript_cleaned$title <- str_extract(Ptranscript_cleaned$doc_id, "\\d+_\\d+_\\d+_\\s*(.*?)\\.docx")

#splits the cleaned transcript to individual words so that we can run an sentiment analysis on it
Ptranscript_split <- Ptranscript_cleaned %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

##1562.74 words per podcast average

#Articles cleaning
VoxA_transcript <- readRDS("../data/vox_articles/2024_all_vox_articles.rds")


VoxA_cleaned <- VoxA_transcript %>%
  mutate(text = str_remove_all(text, "[^[:alpha:][:space:]]"), doc_id = title, date = datetime)
VoxA_cleaned$date <- format(VoxA_cleaned$date, "%Y-%m-%d")
VoxA_cleaned$date <- as.Date(VoxA_cleaned$date, format = "%Y-%m-%d")

VoxA_split <- VoxA_cleaned %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word")

##680.40 words per article average

