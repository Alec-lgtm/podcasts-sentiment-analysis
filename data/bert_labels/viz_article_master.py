import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import numpy as np
import os
from pathlib import Path

def ensure_dir(directory: str) -> str:
    """Create directory if it doesn't exist and return the path."""
    dir_path = Path(directory)
    dir_path.mkdir(parents=True, exist_ok=True)
    return str(dir_path)

def save_figure(fig: plt.Figure, filename: str, directory: str = "../../figures/") -> None:
    """Save figure to specified directory with given filename."""
    save_path = Path(ensure_dir(directory)) / filename
    fig.savefig(save_path, bbox_inches='tight', dpi=300)
    print(f"Figure saved: {save_path}")

def plot_sentiment_trends(df: pd.DataFrame,
                         date_col: str = 'datetime',
                         sentiment_col: str = 'sentiment_score',
                         figsize: tuple = (15, 6)) -> None:
    """Plot sentiment trends with daily values and rolling averages."""
    fig = plt.figure(figsize=figsize)

    daily_sentiment = df.groupby(pd.to_datetime(df[date_col]).dt.date)[sentiment_col].mean().reset_index()
    daily_sentiment.set_index(date_col, inplace=True)

    rolling_7day = daily_sentiment[sentiment_col].rolling(window=7).mean()
    rolling_30day = daily_sentiment[sentiment_col].rolling(window=30).mean()

    plt.plot(daily_sentiment.index, daily_sentiment[sentiment_col],
             color='blue', alpha=0.2, linewidth=1, label='Daily')
    plt.plot(daily_sentiment.index, rolling_7day,
             color='red', linewidth=2, label='7-day Rolling Average')
    plt.plot(daily_sentiment.index, rolling_30day,
             color='green', linewidth=2, label='30-day Rolling Average')

    plt.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    plt.title('Article Sentiment Trends', fontsize=14, pad=20)
    plt.ylabel('Sentiment Score (-1 to 1)', fontsize=12)
    plt.xlabel('Date', fontsize=12)
    plt.grid(True, alpha=0.2)
    plt.legend()
    plt.xticks(rotation=45)

    save_figure(fig, "sentiment_trends.png")
    plt.show()

def plot_sentiment_score_distribution(df: pd.DataFrame,
                                   pos_col: str = 'pos_score',
                                   neg_col: str = 'neg_score',
                                   bins: int = 30,
                                   figsize: tuple = (10, 5)) -> None:
    """Plot histogram distribution of positive and negative sentiment scores."""
    fig = plt.figure(figsize=figsize)

    plt.hist(df[pos_col], bins=bins, alpha=0.7, label="Positive Score", color='blue')
    plt.hist(df[neg_col], bins=bins, alpha=0.7, label='Negative Score', color='red')

    plt.title('Distribution of Sentiment Scores')
    plt.xlabel('Score')
    plt.ylabel('Frequency')
    plt.legend()

    save_figure(fig, "sentiment_distribution.png")
    plt.show()

def plot_sentiment_counts(df: pd.DataFrame,
                         sentiment_col: str = 'sentiment',
                         figsize: tuple = (8, 5)) -> None:
    """Plot bar chart of sentiment value counts."""
    fig = plt.figure(figsize=figsize)

    sentiment_counts = df[sentiment_col].value_counts()
    sentiment_counts.plot(kind='bar', color=['red', 'blue'])

    plt.title('Sentiment Distribution')
    plt.xlabel('Sentiment')
    plt.ylabel('Count')

    save_figure(fig, "sentiment_counts.png")
    plt.show()

def plot_monthly_distribution(df: pd.DataFrame,
                            date_col: str = 'datetime',
                            sentiment_col: str = 'sentiment_score',
                            figsize: tuple = (15, 6)) -> None:
    """Plot monthly sentiment distribution as boxplots."""
    fig = plt.figure(figsize=figsize)

    df = df.copy()
    df['month'] = pd.to_datetime(df[date_col]).dt.to_period('M')

    sns.boxplot(data=df, x='month', y=sentiment_col)
    plt.title('Monthly Sentiment Distribution', fontsize=14, pad=20)
    plt.xlabel('Month', fontsize=12)
    plt.ylabel('Sentiment Score', fontsize=12)
    plt.xticks(rotation=45)
    plt.grid(True, alpha=0.2)

    save_figure(fig, "monthly_distribution.png")
    plt.show()

def plot_author_analysis(df: pd.DataFrame,
                        author_col: str = 'author',
                        sentiment_col: str = 'sentiment_score',
                        min_articles: int = 5,
                        top_n: int = 10,
                        figsize: tuple = (12, 8)) -> None:
    """Plot average sentiment by author."""
    fig = plt.figure(figsize=figsize)

    author_stats = df.groupby(author_col).agg({
        sentiment_col: ['mean', 'count']
    }).reset_index()
    author_stats.columns = [author_col, 'mean_sentiment', 'article_count']

    author_stats = author_stats[author_stats['article_count'] >= min_articles]
    author_stats = author_stats.sort_values('mean_sentiment', ascending=True)

    plt.barh(range(min(top_n, len(author_stats))),
             author_stats['mean_sentiment'].head(top_n),
             alpha=0.6)
    plt.yticks(range(min(top_n, len(author_stats))),
               author_stats[author_col].head(top_n))
    plt.title(f'Average Sentiment by Top Authors (min. {min_articles} articles)',
              fontsize=14, pad=20)
    plt.xlabel('Average Sentiment Score', fontsize=12)
    plt.axvline(x=0, color='gray', linestyle='--', alpha=0.3)
    plt.grid(True, alpha=0.2)

    save_figure(fig, "author_analysis.png")
    plt.show()

def plot_base_sentiment_trends(df: pd.DataFrame,
                             date_col: str = 'datetime',
                             sentiment_col: str = 'sentiment_score',
                             figsize: tuple = (15, 8)) -> None:
    """Plot base sentiment trends without rolling averages."""
    df = df.copy()
    df[date_col] = pd.to_datetime(df[date_col], format='mixed')

    daily_sentiment = df.groupby(df[date_col].dt.date)[sentiment_col].mean().reset_index()

    fig = plt.figure(figsize=figsize)

    plt.plot(daily_sentiment[date_col], daily_sentiment[sentiment_col],
             color='blue', linewidth=2, alpha=0.7)

    plt.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

    plt.fill_between(daily_sentiment[date_col],
                     daily_sentiment[sentiment_col],
                     0,
                     where=(daily_sentiment[sentiment_col] >= 0),
                     color='green',
                     alpha=0.2,
                     label='Positive Sentiment')
    plt.fill_between(daily_sentiment[date_col],
                     daily_sentiment[sentiment_col],
                     0,
                     where=(daily_sentiment[sentiment_col] <= 0),
                     color='red',
                     alpha=0.2,
                     label='Negative Sentiment')

    plt.title('Article Sentiment Over Time', fontsize=14, pad=20)
    plt.xlabel('Date', fontsize=12)
    plt.ylabel('Sentiment Score (-1 to 1)', fontsize=12)
    plt.grid(True, alpha=0.2)
    plt.legend()
    plt.xticks(rotation=45)

    plt.figtext(0.02, 0.02,
                'Daily average sentiment scores.\nPositive values indicate positive sentiment, negative values indicate negative sentiment.',
                fontsize=8, alpha=0.7)

    save_figure(fig, "base_sentiment_trends.png")
    plt.show()

def print_sentiment_analysis(df: pd.DataFrame,
                           date_col: str = 'datetime',
                           sentiment_col: str = 'sentiment_score',
                           author_col: str = 'author') -> None:
    """Print sentiment analysis statistics."""
    df = df.copy()
    df['month'] = pd.to_datetime(df[date_col]).dt.to_period('M')

    print("\nSentiment Analysis Summary:")
    print(f"Overall average sentiment: {df[sentiment_col].mean():.3f}")
    print(f"Median sentiment: {df[sentiment_col].median():.3f}")
    print(f"Percentage of positive articles: {(df[sentiment_col] > 0).mean() * 100:.1f}%")

def analyze_sentiment(df: pd.DataFrame,
                     date_col: str = 'datetime',
                     sentiment_col: str = 'sentiment_score',
                     author_col: str = 'author') -> None:
    """Run complete sentiment analysis with all plots and statistics."""
    # Distribution plots
    plot_sentiment_score_distribution(df)
    plot_sentiment_counts(df)

    # Time series plots
    plot_base_sentiment_trends(df, date_col, sentiment_col)
    plot_sentiment_trends(df, date_col, sentiment_col)
    plot_monthly_distribution(df, date_col, sentiment_col)

    # Author analysis
    plot_author_analysis(df, author_col, sentiment_col)

    # Print statistics
    print_sentiment_analysis(df, date_col, sentiment_col, author_col)

if __name__ == "__main__":
    try:

        df = pd.read_csv('vox_articles_longform.csv')
        # Convert datetime string to datetime object
        df['datetime'] = pd.to_datetime(df['datetime'], format='mixed')

        # Calculate sentiment score
        df['sentiment_score'] = df['pos_score'] - df['neg_score']

        # df = pd.read_csv("../../data/bert_labels/vox_articles_longform.csv")

        # Run analysis
        analyze_sentiment(df)

    except FileNotFoundError:
        print("Please provide the correct path to your data file.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
