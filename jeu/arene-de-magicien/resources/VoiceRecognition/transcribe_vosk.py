#!/usr/bin/env python3
# Simple script pour transcrire un WAV mono 16kHz en utilisant Vosk.
# Usage: python transcribe_vosk.py <wavfile> <model_path>

import sys
import wave
import json

def main():
    if len(sys.argv) < 3:
        print("Usage: transcribe_vosk.py <wavfile> <model_path>", file=sys.stderr)
        sys.exit(1)

    wav_path = sys.argv[1]
    model_path = sys.argv[2]

    try:
        from vosk import Model, KaldiRecognizer
    except Exception as e:
        print("Erreur: impossible d'importer vosk. Installez via: pip install vosk", file=sys.stderr)
        sys.exit(2)

    try:
        wf = wave.open(wav_path, "rb")
    except Exception as e:
        print(f"Impossible d'ouvrir le fichier wav: {e}", file=sys.stderr)
        sys.exit(3)

    if wf.getnchannels() != 1 or wf.getsampwidth() != 2:
        # Le fichier doit être mono 16 bits. Si ffmpeg a été utilisé avec -ac 1 -ar 16000, c'est OK.
        pass

    try:
        model = Model(model_path)
    except Exception as e:
        print(f"Impossible de charger le modèle Vosk depuis '{model_path}': {e}", file=sys.stderr)
        sys.exit(4)

    rec = KaldiRecognizer(model, wf.getframerate())
    results = []
    while True:
        data = wf.readframes(4000)
        if len(data) == 0:
            break
        if rec.AcceptWaveform(data):
            res = json.loads(rec.Result())
            if "text" in res and res["text"].strip() != "":
                results.append(res["text"].strip())
    final = json.loads(rec.FinalResult())
    if "text" in final and final["text"].strip() != "":
        results.append(final["text"].strip())

    text = " ".join(results).strip()
    print(text)

if __name__ == "__main__":
    main()