#!/bin/bash
set -e

echo "Setting up models directory..."
mkdir -p models

# Always remove old files to ensure clean download
rm -f models/jarvis-medium.onnx models/jarvis-medium.onnx.json

echo "Downloading Jarvis voice model..."
wget -q --show-progress -L https://github.com/rhasspy/piper/releases/download/v1.2.0/jarvis-medium.onnx -O models/jarvis-medium.onnx
wget -q --show-progress -L https://github.com/rhasspy/piper/releases/download/v1.2.0/jarvis-medium.onnx.json -O models/jarvis-medium.onnx.json

echo "Verifying downloads..."
ls -la models/

echo "Starting application..."
exec python main.py