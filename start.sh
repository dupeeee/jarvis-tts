#!/bin/bash
set -e

echo "=== Setting up models directory ==="
mkdir -p models
cd models

# Remove old files
rm -f jarvis-medium.onnx jarvis-medium.onnx.json

echo "=== Downloading model files from Hugging Face ==="
echo "Downloading ONNX model..."
curl -fL --progress-bar \
  -o jarvis-medium.onnx \
  "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en_US/jarvis/medium/jarvis-medium.onnx"

echo "Downloading config JSON..."
curl -fL --progress-bar \
  -o jarvis-medium.onnx.json \
  "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en_US/jarvis/medium/jarvis-medium.onnx.json"

echo "=== Verifying files ==="
ls -la
file jarvis-medium.onnx.json
head -c 200 jarvis-medium.onnx.json

echo ""
echo "=== Starting application ==="
cd ..
exec python main.py