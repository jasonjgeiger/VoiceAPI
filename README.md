# VoiceAPI

A simple Flask API server for text-to-speech using ElevenLabs and mpg321 audio playback.

## Requirements
- Python 3.7+
- [mpg321](https://packages.debian.org/mpg321) (for audio playback)
- ElevenLabs API key

## Installation

1. **Clone the repository:**
   ```bash
   git clone <your_repo_url>
   cd VoiceAPI
   ```

2. **Run the install script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   - The script will install all required system and Python dependencies, including [gunicorn](https://gunicorn.org/) to `~/.local/bin` for production use.
   - If `~/.local/bin` is not in your PATH, the script will add it to your `~/.bashrc` and prompt you to log out and back in.
   - You will be prompted to enter your ElevenLabs API key (if not already set). This key will be saved to a `.env` file in the project directory.
   - **After installation, you will be prompted to set up VoiceAPI as a user systemd service to run in the background using gunicorn.**

3. **If you do not use the systemd user service:**
   - **Load your environment variables:**
     ```bash
     source .env
     ```
   - **Run the server with gunicorn (recommended for production):**
     ```bash
     ~/.local/bin/gunicorn --bind 0.0.0.0:5000 script:app
     ```
   - The server will start on port 5000.
   - **For development only:**
     ```bash
     python3 script.py
     ```
     (You may see a warning about the Flask development server. Use gunicorn for production.)

## Running as a Background Service (systemd user service)
If you choose to set up the user systemd service during installation, VoiceAPI will run in the background using gunicorn and start automatically on login.

- The service file is created at `~/.config/systemd/user/voiceapi.service`.
- **Do not use sudo for user services.**
- **Do not edit /etc/systemd/system/voiceapi.service.**

**Service management commands:**
- Check status:   `systemctl --user status voiceapi`
- View logs:      `journalctl --user -u voiceapi -f`
- Stop service:   `systemctl --user stop voiceapi`
- Start service:  `systemctl --user start voiceapi`

If you update your PATH, log out and back in for changes to take effect in new terminals.

## Usage

### Text-to-Speech
Send a GET or POST request to `/tts` with `text` and (optionally) `voice_id` as query parameters:
```bash
curl "http://localhost:5000/tts?text=Hello"
```
Or send JSON:
```bash
curl -X POST http://localhost:5000/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello"}'
```

### Stop Playback
Send a POST request to `/stop`:
```bash
curl -X POST http://localhost:5000/stop
```

## Troubleshooting
- If you do not hear audio, make sure your user has access to the audio device and try running the server in the foreground to test.
- If `gunicorn` is not found, make sure `~/.local/bin` is in your PATH and log out/in if needed.
- If you see port conflicts, ensure no other process is using port 5000.
- For user systemd services, do not use `User=` or `Group=` in the service file.

## Notes
- The API key is saved in the `.env` file and must be loaded with `source .env` before running the server manually.
- Only one audio playback can run at a time; new requests will stop the previous playback.
- If you need to change your API key, you can rerun the install script or edit the `.env` file directly.
- **Warning:** The Flask development server is not suitable for production. Always use gunicorn for production deployments. 