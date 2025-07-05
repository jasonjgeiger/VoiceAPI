#!/bin/bash
set -e

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
  export PATH="$PATH:$HOME/.local/bin"
  echo "[VoiceAPI] Added ~/.local/bin to PATH in ~/.bashrc. Please log out and back in for this to take effect in new terminals."
fi

# Install system dependencies
echo "[VoiceAPI] Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip mpg321

# Install Python dependencies
echo "[VoiceAPI] Installing Python dependencies..."
pip3 install --upgrade pip
pip3 install --user -r requirements.txt
pip3 install --user gunicorn

# Prompt for API key if not set
if [ -z "$ELEVENLABS_API_KEY" ]; then
  read -p "Enter your ElevenLabs API key: " api_key
else
  api_key="$ELEVENLABS_API_KEY"
fi

echo "ELEVENLABS_API_KEY=$api_key" > .env

# Set up user systemd service
read -p "Would you like to set up VoiceAPI as a user systemd service to run in the background? (y/n): " setup_service
if [[ "$setup_service" =~ ^[Yy]$ ]]; then
  mkdir -p ~/.config/systemd/user
  GUNICORN_PATH="$HOME/.local/bin/gunicorn"
  WORKDIR="$(pwd)"
  ENV_PATH="$WORKDIR/.env"
  SERVICE_FILE="$HOME/.config/systemd/user/voiceapi.service"
  cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=VoiceAPI Flask Server (gunicorn)
After=network.target

[Service]
WorkingDirectory=$WORKDIR
EnvironmentFile=$ENV_PATH
ExecStart=$GUNICORN_PATH --bind 0.0.0.0:5000 script:app
Restart=always

[Install]
WantedBy=default.target
EOL

  systemctl --user daemon-reload
  systemctl --user enable voiceapi
  systemctl --user restart voiceapi

  echo "\n[VoiceAPI] User systemd service installed and started using gunicorn."
  echo "To check status:   systemctl --user status voiceapi"
  echo "To view logs:      journalctl --user -u voiceapi -f"
  echo "To stop service:   systemctl --user stop voiceapi"
  echo "To start service:  systemctl --user start voiceapi"
else
  echo "\nYou can always set up the user systemd service later by re-running this script."
fi

echo "\n[VoiceAPI] Installation complete."
echo "Your ElevenLabs API key has been saved to .env."
echo "Before running the server, load your environment variables with:"
echo "  source .env"
echo "Then start the server with:"
echo "  $HOME/.local/bin/gunicorn --bind 0.0.0.0:5000 script:app"
echo "\n[VoiceAPI] For production deployments, gunicorn is now used as the WSGI server." 