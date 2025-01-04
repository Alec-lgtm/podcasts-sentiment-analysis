import pandas as pd
from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline
from tqdm import tqdm
import time
from datetime import timedelta
import torch

def chunk_and_analyze(text, analyzer, chunk_size=400):
    words = text.split()
    chunks = [' '.join(words[i:i + chunk_size]) for i in range(0, len(words), chunk_size - 50)]
    # Get all scores for each chunk
    sentiments = [analyzer(chunk, return_all_scores=True)[0] for chunk in chunks]

    # Find chunk with most extreme sentiment (furthest from neutral)
    max_diff = 0
    max_sentiment = None
    for chunk_sentiments in sentiments:
        # Get difference between positive and negative scores
        pos_score = next(s['score'] for s in chunk_sentiments if s['label'] == 'POSITIVE')
        neg_score = next(s['score'] for s in chunk_sentiments if s['label'] == 'NEGATIVE')
        diff = abs(pos_score - neg_score)
        if diff > max_diff:
            max_diff = diff
            max_sentiment = chunk_sentiments

    return max_sentiment

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
    tokenizer=tokenizer,
    truncation=True,
    max_length=512,
    device=device
)

# Test on one article to see the format
test_result = sentiment_analyzer("This is a test", return_all_scores=True)
print("Sample output format:")
print(test_result[0])

# Process all articles with visible progress bar
df = pd.read_csv('../../data/vox_articles/2024_all_vox_articles.csv')
results = []
for index, row in tqdm(df.iterrows(), total=len(df), desc="Analyzing articles"):
    sentiment = chunk_and_analyze(row['text'], sentiment_analyzer)
    results.append(sentiment)

# Convert results to DataFrame columns - now storing both scores
df['pos_score'] = [[s['score'] for s in r if s['label'] == 'POSITIVE'][0] for r in results]
df['neg_score'] = [[s['score'] for s in r if s['label'] == 'NEGATIVE'][0] for r in results]
df['sentiment'] = ['POSITIVE' if pos > neg else 'NEGATIVE' for pos, neg in zip(df['pos_score'], df['neg_score'])]

# Save to CSV
df.to_csv('vox_articles_with_sentiment.csv', index=False)
