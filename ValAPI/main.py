import os
import requests
import yaml
import time

# Load tokens from YAML file
with open('ValAPI\\secret.yaml', 'r') as file:
    token = yaml.safe_load(file)

clientSecret = token['clientSecret']

# API endpoints
base_url = "https://api.riotgames.com"
playerName = token['playerName']  # Replace with actual player name
tagLine = token['playerTagline']  # Replace with actual player tagline

#use this to find puuid
puuidUrl = f'https://americas.api.riotgames.com/riot/account/v1/accounts/by-riot-id/{playerName}/{tagLine}?api_key={clientSecret}'

# Headers for authentication
headers = {
    'X-Riot-Token': clientSecret
}

# Get player's PUUID (Player Unique Identifier)
response = requests.get(puuidUrl, headers=headers)

if response.status_code == 200:
    player_data = response.json()
    puuid = player_data['puuid']
    print(f"Player PUUID: {puuid}")
else:
    print(f"Failed to get player PUUID. Error: {response.status_code}")
    exit()

# Correct match history endpoint
matches_url = f"https://{region}.api.riotgames.com/val/match/console/v1/matchlists/by-puuid/{puuid}"

# Optional parameters (adjust if needed)
params = {
    'queue': 'competitive',  # For competitive match history
    'start': 0,  # Start index for the matches
    'count': 10  # Number of matches to retrieve, change as needed
}

# Fetching match history
response = requests.get(matches_url, headers=headers, params=params)

if response.status_code == 200:
    match_history = response.json()
    for match in match_history['matches']:
        print(f"Match ID: {match['matchId']}, Played on: {time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(match['gameStartTime'] / 1000))}")
else:
    print(f"Failed to retrieve match history. Error: {response.status_code} - {response.text}")
