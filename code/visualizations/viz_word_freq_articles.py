import os
import re
from collections import Counter
import matplotlib.pyplot as plt
from wordcloud import WordCloud
import pandas as pd
import seaborn as sns
from nltk.corpus import stopwords
import nltk
from pathlib import Path

def setup_nltk():
    """Download required NLTK data if not already present."""
    try:
        nltk.data.find('corpora/stopwords')
    except LookupError:
        nltk.download('stopwords', quiet=True)

def tokenize_and_filter(text):
    """Clean, tokenize, and remove stop words from text."""
    stop_words = set(stopwords.words('english'))
    # Add custom stop words relevant to news articles
    custom_stop_words = {'com', 'vox', 'www', 'https', 'article', 'news'}
    stop_words.update(custom_stop_words)

    # Convert to string in case input is not string
    text = str(text)

    # Remove URLs
    text = re.sub(r'http\S+|www.\S+', '', text)

    # Remove non-word characters
    text = re.sub(r'\W+', ' ', text)

    tokens = text.lower().split()
    return [word for word in tokens if word not in stop_words and len(word) > 1]

def process_csv_data(csv_file):
    """Process CSV file and return word counts."""
    try:
        # Read CSV file
        df = pd.read_csv(csv_file)

        # Combine title and text columns for analysis
        df['combined_text'] = df['title'] + ' ' + df['text']

        # Process each article
        word_counts = Counter()

        for text in df['combined_text']:
            words = tokenize_and_filter(text)
            if words:  # Check if any words remain after filtering
                word_counts.update(words)

        return word_counts

    except Exception as e:
        print(f"Error processing CSV file: {str(e)}")
        return Counter()

def create_visualizations(combined_counts, output_dir="output"):
    """Create and save word frequency visualizations."""
    # Create output directory if it doesn't exist
    Path(output_dir).mkdir(exist_ok=True)

    # Create word cloud
    wordcloud = WordCloud(width=1600, height=800, background_color='white').generate_from_frequencies(combined_counts)
    plt.figure(figsize=(20,10))
    plt.imshow(wordcloud, interpolation='bilinear')
    plt.axis('off')
    plt.title('Word Cloud of Vox Articles')
    plt.savefig(Path(output_dir) / 'vox_articles_wordcloud.png', bbox_inches='tight', dpi=300)
    plt.close()

    # Create bar plot of top words
    top_words_df = pd.DataFrame(combined_counts.most_common(20), columns=['Word', 'Count'])
    plt.figure(figsize=(15,8))
    sns.barplot(data=top_words_df, x='Word', y='Count')
    plt.xticks(rotation=45, ha='right')
    plt.title('Top 20 Most Frequent Words in Vox Articles')
    plt.tight_layout()
    print(Path(output_dir).resolve() / "hello")
    plt.savefig(Path(output_dir).resolve() / 'vox_articles_top_words.png', bbox_inches='tight', dpi=300)
    plt.close()

def main():
    # Set up file paths 
    csv_file = "../../data/vox_articles/2024_all_vox_articles.csv"
    output_dir = "../../figures"

    try:
        # Set up NLTK
        setup_nltk()

        # Process CSV data
        word_counts = process_csv_data(csv_file)

        if not word_counts:
            print("No valid text was processed.")
            return

        # Create visualizations
        create_visualizations(word_counts, output_dir)

        # Print summary statistics
        print(f"Total unique words: {len(word_counts)}")
        print("\nTop 10 most common words:")
        for word, count in word_counts.most_common(10):
            print(f"{word}: {count}")

    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    main()
