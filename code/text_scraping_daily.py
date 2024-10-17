import requests
from bs4 import BeautifulSoup
import feedparser
import time

# Step 1: Parse the RSS feed to get episode URLs
rss_url = 'https://feeds.megaphone.fm/VMP5705694065'
feed = feedparser.parse(rss_url)

# Step 2: Define a function to scrape the transcript from an episode page
def get_transcript(episode_url):
    response = requests.get(episode_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Adjust this part based on actual page structure. Example class for transcript.
    transcript = soup.find('div', class_='transcript-text-class')  # Replace with actual class
    
    if transcript:
        return transcript.get_text()
    else:
        print(f"Transcript not found for: {episode_url}")
        return None

# Step 3: Loop through episodes in the RSS feed and scrape transcripts
for entry in feed.entries:
    # Try multiple possible attributes for the URL
    episode_url = entry.get('link', entry.get('guid', None))  # Use 'link' if available, otherwise 'guid'
    
    if episode_url:
        print(f"Fetching transcript from: {episode_url}")
        
        transcript = get_transcript(episode_url)
        
        if transcript:
            # Save transcript to a file, using the episode title or date for filename
            filename = entry.title.replace(' ', '_') + '.txt'
            with open(filename, 'w') as f:
                f.write(transcript)
            print(f"Saved transcript to {filename}")
        
        # Step 4: Add a delay to avoid overloading the server
        time.sleep(2)
    else:
        print("No valid URL found for this entry.")

