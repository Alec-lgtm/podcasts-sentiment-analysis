import os
import re
from collections import Counter
import matplotlib.pyplot as plt
from wordcloud import WordCloud
import pandas as pd
import seaborn as sns
from nltk.corpus import stopwords
from docx import Document
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
    text = re.sub(r'\W+', ' ', text)  # Remove non-word characters
    tokens = text.lower().split()
    return [word for word in tokens if word not in stop_words and len(word) > 1]

def process_docx_files(directory):
    """Process all .docx files in the directory and return word counts."""
    directory_path = Path(directory)
    word_counts = {}

    if not directory_path.exists():
        raise FileNotFoundError(f"Directory not found: {directory}")

    for filepath in directory_path.glob("*.docx"):
        try:
            doc = Document(filepath)
            text = " ".join(paragraph.text for paragraph in doc.paragraphs)
            words = tokenize_and_filter(text)

            if words:  # Check if any words remain after filtering
                word_counts[filepath.name] = Counter(words)
        except Exception as e:
            print(f"Error processing {filepath.name}: {str(e)}")

    return word_counts

def create_visualizations(combined_counts, output_dir="output"):
    """Create and save word frequency visualizations."""
    # Create output directory if it doesn't exist
    Path(output_dir).mkdir(exist_ok=True)

    # Create word cloud
    wordcloud = WordCloud(width=1600, height=800, background_color='white').generate_from_frequencies(combined_counts)
    plt.figure(figsize=(20,10))
    plt.imshow(wordcloud, interpolation='bilinear')
    plt.axis('off')
    plt.savefig(Path(output_dir) / 'vox_podcasts_wordcloud.png', bbox_inches='tight', dpi=300)
    plt.close()

    # Create bar plot of top words
    top_words_df = pd.DataFrame(combined_counts.most_common(20), columns=['Word', 'Count'])
    plt.figure(figsize=(15,8))
    sns.barplot(data=top_words_df, x='Word', y='Count')
    plt.xticks(rotation=45, ha='right')
    plt.title('Top 20 Most Frequent Words')
    plt.tight_layout()
    plt.savefig(Path(output_dir) / 'vox_podcasts_top_words.png', bbox_inches='tight', dpi=300)
    plt.close()

def main():
    # Set up configuration
    directory = "../../data/vox_podcasts/2024/"
    output_dir = "../../figures/"

    try:
        # Set up NLTK
        setup_nltk()

        # Process files
        word_counts = process_docx_files(directory)

        if not word_counts:
            print("No valid documents were processed.")
            return

        # Combine all word counts
        combined_counts = Counter()
        for wc in word_counts.values():
            combined_counts.update(wc)

        # Create visualizations
        create_visualizations(combined_counts, output_dir)

        # Print summary statistics
        print(f"Processed {len(word_counts)} documents")
        print(f"Total unique words: {len(combined_counts)}")
        print("\nTop 10 most common words:")
        for word, count in combined_counts.most_common(10):
            print(f"{word}: {count}")

    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    main()
