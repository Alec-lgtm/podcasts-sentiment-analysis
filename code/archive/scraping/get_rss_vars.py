
import feedparser

# RSS feed URL of the podcast
rss_url = 'https://feeds.simplecast.com/54nAGcIl'

# https://feeds.megaphone.fm/GLT1412515089'

# Joe Rogan: https://feeds.megaphone.fm/GLT1412515089

# https://feeds.simplecast.com/54nAGcIl

# Parse the RSS feed
feed = feedparser.parse(rss_url)

print(feed.feed)

# Extract and print podcast information
print(f"Podcast Title: {feed['feed']['title']}")
print(f"Podcast Description: {feed['feed']['description']}")

print("\nEpisodes:")
for episode in feed['entries']:
    title = episode.get('title', 'No title')
    description = episode.get('description', 'No description')
    pub_date = episode.get('published', 'No date')
    audio_url = episode.get('enclosures')[0]['href'] if episode.get('enclosures') else 'No audio file'

    print(f"Title: {title}")
    print(f"Description: {description}")
    print(f"Published Date: {pub_date}")
    print(f"Audio URL: {audio_url}")
    print('-' * 40)
