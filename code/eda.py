import os
import re
from collections import Counter
import matplotlib.pyplot as plt
from wordcloud import WordCloud
import pandas as pd
import seaborn as sns

# Specify the directory where the .docx files are located
directory = "../data/vox_podcasts"

# Function to clean and tokenize text
def tokenize(text):
    text = re.sub(r'\W+', ' ', text)  # Remove non-word characters
    return text.lower().split()

# Dictionary to store word counts for each file
word_counts = {}

# Process each file in the directory
for filename in os.listdir(directory):
    if filename.endswith(".docx"):
        filepath = os.path.join(directory, filename)

        # Read the file (assuming text extraction from .docx is handled here)
        # For example, using python-docx library:
        from docx import Document
        doc = Document(filepath)
        text = " ".join([paragraph.text for paragraph in doc.paragraphs])

        # Tokenize and count words
        words = tokenize(text)
        word_counts[filename] = Counter(words)

# Combine all word counts
combined_counts = Counter()
for wc in word_counts.values():
    combined_counts.update(wc)

# Convert to DataFrame for easier plotting
df = pd.DataFrame(combined_counts.items(), columns=['Word', 'Frequency']).sort_values(by='Frequency', ascending=False)

# Visualization 1: Top 20 Most Frequent Words
plt.figure(figsize=(10, 6))
sns.barplot(data=df.head(20), x='Frequency', y='Word')
plt.title('Top 20 Most Frequent Words')
plt.xlabel('Frequency')
plt.ylabel('Word')
plt.show()

# Visualization 2: Word Frequency Distribution
plt.figure(figsize=(10, 6))
plt.hist(df['Frequency'], bins=50, log=True)
plt.title('Word Frequency Distribution')
plt.xlabel('Frequency')
plt.ylabel('Number of Words')
plt.show()

# Visualization 3: Word Cloud
wordcloud = WordCloud(width=800, height=400, max_words=100).generate_from_frequencies(combined_counts)
plt.figure(figsize=(10, 5))
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis('off')
plt.title('Word Cloud of All Documents')
plt.show()

# Visualization 4: Unique Word Count Across Files
unique_words = [len(wc) for wc in word_counts.values()]
file_names = list(word_counts.keys())

plt.figure(figsize=(10, 6))
sns.barplot(x=file_names, y=unique_words)
plt.xticks(rotation=90)
plt.title('Unique Word Count per Document')
plt.xlabel('Document')
plt.ylabel('Unique Words')
plt.show()

