from flask import Flask, jsonify, request
from elevenlabs.client import ElevenLabs
import subprocess
import os

app = Flask(__name__)

# Load ElevenLabs API key from environment variable
api_key = os.environ.get("ELEVENLABS_API_KEY")
if not api_key:
    raise RuntimeError("ELEVENLABS_API_KEY environment variable not set.")
client = ElevenLabs(api_key=api_key)
mpg321_process = None

@app.route('/tts', methods=['POST'])
def text_to_speech():
    global mpg321_process
    data = request.get_json()
    text = data.get('text')
    voice_id = data.get('voice_id', 'JBFqnCBsd6RMkjVDRZzb')

    if not text:
        return jsonify({"error": "Text is required"}), 400

    # Stop any existing playback
    if mpg321_process:
        mpg321_process.terminate()
        mpg321_process = None

    # Generate audio
    output_file = "output.mp3"
    audio = client.text_to_speech.convert(
        voice_id=voice_id,
        text=text,
        voice_settings={"stability": 0.7, "similarity_boost": 0.8}
    )

    # Save audio
    with open(output_file, "wb") as f:
        for chunk in audio:
            f.write(chunk)

    # Play with mpg321
    try:
        mpg321_process = subprocess.Popen(['mpg321', output_file])
        return jsonify({"message": f"Playing text: {text}"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/stop', methods=['POST'])
def stop_playback():
    global mpg321_process
    if mpg321_process:
        mpg321_process.terminate()
        mpg321_process = None
        return jsonify({"message": "Playback stopped"}), 200
    return jsonify({"error": "No active playback"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)