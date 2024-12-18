# Sentiment analysis on Vox Podcasts and Articles

Project by Aki Wada and Alec Chen

---

## Table of Contents

- [About the Project](#about-the-project)
- [Getting Started](#getting-started)
- [Overview](#Overview)
- [Acknowledgement](#Acknowledgement)

---

## About the Project

This project is sentiment analysis of vox articles and podcasts using the `syzuhet` library.

**Built With**

- [R](https://www.r-project.org)
- [Python](https://www.python.org/)

---

## Getting Started

Install these Python libraries:

```bash
pip install matplotlib wordcloud pandas seaborn nltk python-docx
```

Also make sure to download these stop words:

```python
import nltk
nltk.download('stopwords')
```

Install these R libraries:

```R
install.packages(c("tidyverse", "rvest", "stringr", "logging", 
                   "syuzhet", "tm", "ggplot2", "readtext", 
                   "tidytext", "zoo"))
```

## Overivew

**Blog**

This is a standalong blog that walks you through our analysis process. To read it, open the `blog.html` file

**Scraping**

To run the scraping script, navigate to the `code/scraping/` directory and run the following command in your R console:

```R
source("run_scraper.R")
```

**Visualizations**

There are three scripts we used to create these visualizations. They are all located in the `code/visualizations/` directory. To run the word frequency visualizations created by python scripts use the following command:

```Python
python viz_word_freq_articles.py
```

The figures from the python script will be located in the `figures/` directory.

For the `syzuhet` visualizations, you can either open the `viz_sentiment.qmd` to run each code chunk in a quarto document, or navigate to the visualizations directory and run the following script in your R console:

```R
source("viz_sentiment_no_headings.R")
```

This script does the data cleaning and visualization for `syzuhet` and stores the data in an R workspace located in the `data` directory

## Acknowledgement

We like to thank our Professor Brianna Heggeseth for all the work she'd done to help us grow through this project. It couldn't have been done without her.

