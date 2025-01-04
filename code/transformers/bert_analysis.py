import pandas as pd
from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline
from tqdm import tqdm
import time
from datetime import timedelta
import torch

def chunk_and_analyze(text, analyzer, chunk_size=400):
    words = text.split()
    chunks = [' '.join(words[i:i + chunk_size]) for i in range(0, len(words), chunk_size - 50)]
    sentiments = [analyzer(chunk)[0] for chunk in chunks]
    overall_sentiment = max(sentiments, key=lambda x: abs(x['score'] - 0.5))
    return overall_sentiment

# Start timer
start_time = time.time()

print("Starting sentiment analysis...")

# Load data
df = pd.read_csv('../../data/vox_articles/2024_all_vox_articles.csv')
print(f"Total articles to process: {len(df)}")

# Setup model with MPS
model_name = "distilbert-base-uncased-finetuned-sst-2-english"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)

# Move model to MPS device
device = torch.device("mps")
model = model.to(device)

sentiment_analyzer = pipeline(
    "sentiment-analysis",
    model=model,
    # return_all_scores=True,
    tokenizer=tokenizer,
    truncation=True,
    max_length=512,
    device=device
)

# Process all articles with visible progress bar
results = []
for index, row in tqdm(df.iterrows(), total=len(df), desc="Analyzing articles"):
    sentiment = chunk_and_analyze(row['text'], sentiment_analyzer)
    results.append(sentiment)

# Convert results to DataFrame columns
df['sentiment'] = [r['label'] for r in results]
df['score'] = [r['score'] for r in results]

# Calculate and display elapsed time
elapsed_time = time.time() - start_time
print(f"\nProcessing completed in: {str(timedelta(seconds=int(elapsed_time)))}")

# Save to CSV
print("Saving results to CSV...")
df.to_csv('../../data/bert_labels/vox_articles_with_sentiment.csv', index=False)
print("Done! Results saved to 'vox_articles_with_sentiment.csv'")

# Display final time
total_time = time.time() - start_time
print(f"Total execution time: {str(timedelta(seconds=int(total_time)))}")
