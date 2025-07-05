#!/bin/bash
set -e

echo "[VoiceAPI] Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip mpg321

echo "[VoiceAPI] Installing Python dependencies..."
pip3 install --upgrade pip
pip3 install -r requirements.txt

# Prompt for API key if not set
if [ -z "$ELEVENLABS_API_KEY" ]; then
  read -p "Enter your ElevenLabs API key: " api_key
else
  api_key="$ELEVENLABS_API_KEY"
fi

echo "ELEVENLABS_API_KEY=$api_key" > .env

echo "\n[VoiceAPI] Installation complete."
echo "Your ElevenLabs API key has been saved to .env."
echo "Before running the server, load your environment variables with:"
echo "  source .env"
echo "Then start the server with:"
echo "  python3 script.py" 