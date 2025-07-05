#!/bin/bash
set -e

echo "[VoiceAPI] Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip mpg321

echo "[VoiceAPI] Installing Python dependencies..."
pip3 install --upgrade pip
pip3 install -r requirements.txt
pip3 install gunicorn

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
echo "  gunicorn --bind 0.0.0.0:5000 script:app"
echo "\n[VoiceAPI] For production deployments, gunicorn is now used as the WSGI server."

echo
read -p "Would you like to set up VoiceAPI as a systemd service to run in the background? (y/n): " setup_service
if [[ "$setup_service" =~ ^[Yy]$ ]]; then
  SERVICE_FILE="/etc/systemd/system/voiceapi.service"
  USERNAME=$(whoami)
  WORKDIR=$(pwd)
  PYTHON_PATH=$(which python3)
  GUNICORN_PATH=$(which gunicorn)
  ENV_PATH="$WORKDIR/.env"

  sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=VoiceAPI Flask Server (gunicorn)
After=network.target

[Service]
User=$USERNAME
WorkingDirectory=$WORKDIR
EnvironmentFile=$ENV_PATH
ExecStart=$GUNICORN_PATH --bind 0.0.0.0:5000 script:app
Restart=always

[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable voiceapi
  sudo systemctl start voiceapi

  echo "\n[VoiceAPI] Systemd service installed and started using gunicorn."
  echo "To check status:   sudo systemctl status voiceapi"
  echo "To view logs:      journalctl -u voiceapi -f"
  echo "To stop service:   sudo systemctl stop voiceapi"
  echo "To start service:  sudo systemctl start voiceapi"
else
  echo "\nYou can always set up the systemd service later by re-running this script."
fi 