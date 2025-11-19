#!/bin/bash

# Installer ffmpeg
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update
    sudo apt install -y ffmpeg python3 python3-pip
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Windows détecté. Veuillez installer ffmpeg manuellement : https://ffmpeg.org/download.html"
    echo "Installez aussi Python3 depuis https://www.python.org/downloads/ et pip si besoin."
    echo "Ensuite, ouvrez un terminal (cmd ou PowerShell) et lancez :"
    echo "    pip install vosk"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "MacOS détecté. Installation via Homebrew :"
    echo "brew install ffmpeg python3"
    echo "pip3 install vosk"
else
    echo "OS non reconnu. Installez ffmpeg, python3 et pip manuellement."
fi

# Installer la librairie vosk (Linux/Mac)
if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    pip3 install vosk
fi

echo "Installation terminée !"
echo "Placez le modèle Vosk dans 'ressources/VoiceRecognition/models/' si ce n'est pas déjà fait."