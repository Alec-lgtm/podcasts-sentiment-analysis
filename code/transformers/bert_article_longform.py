import torch
import pandas as pd
from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline
from tqdm import tqdm

def main():
    # Example: DistilBERT sentiment model with real POSITIVE/NEGATIVE labels
    model_name = "distilbert-base-uncased-finetuned-sst-2-english"

    # Load tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSequenceClassification.from_pretrained(model_name)

    # Set device
    device = torch.device("mps" if torch.backends.mps.is_built()
                          else "cuda" if torch.cuda.is_available()
                          else "cpu")
    model = model.to(device)

    # Define pipeline
    sentiment_analyzer = pipeline(
        "sentiment-analysis",
        model=model,
        tokenizer=tokenizer,
        truncation=True,
        # if you want to handle long text, you might do longer truncation,
        # but DistilBERT typically maxes out near 512 tokens anyway.
        device=device
    )

    # Quick test
    test_result = sentiment_analyzer("This is a test", return_all_scores=True)
    print("Sample output format:")
    print(test_result[0])
    # e.g.: [{'label': 'NEGATIVE', 'score': 0.001}, {'label': 'POSITIVE', 'score': 0.999}]

    # Load your data
    df = pd.read_csv("../../data/vox_articles/2024_all_vox_articles.csv")

    # Analyze
    results = []
    for _, row in tqdm(df.iterrows(), total=len(df), desc="Analyzing articles"):
        # Caution: DistilBERT has a 512 token limit, so you may want
        # some other strategy for very long text (e.g. chunking).
        sentiment = sentiment_analyzer(row['text'], return_all_scores=True)[0]
        results.append(sentiment)

    # Convert results
    df['pos_score'] = [next(s['score'] for s in r if s['label'] == 'POSITIVE') for r in results]
    df['neg_score'] = [next(s['score'] for s in r if s['label'] == 'NEGATIVE') for r in results]
    df['sentiment'] = [
        'POSITIVE' if pos > neg else 'NEGATIVE'
        for pos, neg in zip(df['pos_score'], df['neg_score'])
    ]

    df.to_csv("../../data/bert_labels/vox_articles_longform.csv", index=False)

if __name__ == "__main__":
    main()
