#!/bin/bash
set -e

echo "=== Setting up models directory ==="
mkdir -p models
cd models

# Remove old files
rm -f en_US-lessac-medium.onnx en_US-lessac-medium.onnx.json
rm -f jarvis-medium.onnx jarvis-medium.onnx.json

echo "=== Downloading JARVIS model from Hugging Face ==="
echo "Downloading ONNX model..."
curl -fL --progress-bar \
  -o jarvis-medium.onnx \
  "https://huggingface.co/jgkawell/jarvis/resolve/main/en/en_GB/jarvis/medium/jarvis-medium.onnx"

echo "Downloading config JSON..."
curl -fL --progress-bar \
  -o jarvis-medium.onnx.json \
  "https://huggingface.co/jgkawell/jarvis/resolve/main/en/en_GB/jarvis/medium/jarvis-medium.onnx.json"

echo "=== Verifying files ==="
ls -la
file jarvis-medium.onnx.json
head -c 200 jarvis-medium.onnx.json

echo ""
echo "=== Starting application ==="
cd ..
exec python main.py