#!/bin/bash
set -e

echo "Setting up models directory..."
mkdir -p models

if [ ! -f models/jarvis-medium.onnx ]; then
  echo "Downloading Jarvis voice model..."
  wget -q https://github.com/rhasspy/piper/releases/download/v1.2.0/jarvis-medium.onnx -O models/jarvis-medium.onnx
  wget -q https://github.com/rhasspy/piper/releases/download/v1.2.0/jarvis-medium.onnx.json -O models/jarvis-medium.onnx.json
  echo "Model downloaded successfully!"
else
  echo "Model already exists, skipping download."
fi

echo "Starting application..."
exec python main.py