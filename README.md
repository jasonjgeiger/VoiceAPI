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
   - The script will install all required system and Python dependencies.
   - You will be prompted to enter your ElevenLabs API key (if not already set). This key will be saved to a `.env` file in the project directory.

3. **Load your environment variables:**
   ```bash
   source .env
   ```
   - This step ensures your API key is available to the server.

4. **Run the server:**
   ```bash
   python3 script.py
   ```
   - The server will start on port 5000.

## Usage

### Text-to-Speech
Send a POST request to `/tts` with JSON body:
```json
{
  "text": "Hello world!",
  "voice_id": "JBFqnCBsd6RMkjVDRZzb" // optional
}
```
Example using curl:
```bash
curl -X POST http://localhost:5000/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello world!"}'
```

### Stop Playback
Send a POST request to `/stop`:
```bash
curl -X POST http://localhost:5000/stop
```

## Notes
- The API key is saved in the `.env` file and must be loaded with `source .env` before running the server.
- Only one audio playback can run at a time; new requests will stop the previous playback.
- If you need to change your API key, you can rerun the install script or edit the `.env` file directly. 