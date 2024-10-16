
import feedparser

# RSS feed URL of the podcast
rss_url = 'https://feeds.simplecast.com/54nAGcIl'

# https://feeds.megaphone.fm/GLT1412515089'

# Joe Rogan: https://feeds.megaphone.fm/GLT1412515089

# https://feeds.simplecast.com/54nAGcIl

# Parse the RSS feed
feed = feedparser.parse(rss_url)

# print(feed.feed)
# Function to parse the data
def parse_podcast_info(podcast_data):
    # Extracting main information
    title = podcast_data.get('title', 'N/A')
    subtitle = podcast_data.get('subtitle', 'N/A')
    link = podcast_data.get('link', 'N/A')
    image_url = podcast_data.get('image', {}).get('href', 'N/A')
    summary = podcast_data.get('summary', 'N/A')
    language = podcast_data.get('language', 'N/A')
    rights = podcast_data.get('rights', 'N/A')
    published = podcast_data.get('published', 'N/A')
    updated = podcast_data.get('updated', 'N/A')

    # Extracting author details
    author = podcast_data.get('author', 'N/A')
    authors = podcast_data.get('authors', [{'name': 'N/A', 'email': 'N/A'}])[0]
    author_name = authors.get('name', 'N/A')
    author_email = authors.get('email', 'N/A')

    # Extracting tags
    tags = [tag.get('term', 'N/A') for tag in podcast_data.get('tags', [])]

    # Extracting links
    links = [{"rel": link.get('rel', 'N/A'), "href": link.get('href', 'N/A')} for link in podcast_data.get('links', [])]

    # Print or format the extracted information
    print(f"Podcast Title: {title}")
    print(f"Subtitle: {subtitle}")
    print(f"Link: {link}")
    print(f"Image URL: {image_url}")
    print(f"Summary: {summary}")
    print(f"Language: {language}")
    print(f"Rights: {rights}")
    print(f"Published: {published}")
    print(f"Updated: {updated}")
    print(f"Author: {author} ({author_name} - {author_email})")
    print(f"Tags: {', '.join(tags)}")
    print(f"Links: {links}")

# Call the function
parse_podcast_info(feed.feed)
