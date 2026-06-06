#!/bin/bash
set -e

echo "=== Setting up models directory ==="
mkdir -p models
cd models

# Remove old/partial files
rm -f jarvis-medium.onnx jarvis-medium.onnx.json

echo "=== Downloading JARVIS model from Hugging Face ==="

# Download with retries and better timeout handling
echo "Downloading ONNX model (~60MB)..."
MAX_RETRIES=3
RETRY_COUNT=0

until curl -fL --connect-timeout 30 --max-time 300 \
  -o jarvis-medium.onnx \
  "https://huggingface.co/jgkawell/jarvis/resolve/main/en/en_GB/jarvis/medium/jarvis-medium.onnx"; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "Download failed, retrying ($RETRY_COUNT/$MAX_RETRIES)..."
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "ERROR: Failed to download model after $MAX_RETRIES attempts"
    exit 1
  fi
  sleep 5
done

echo "Downloading config JSON..."
curl -fL --connect-timeout 30 --max-time 60 \
  -o jarvis-medium.onnx.json \
  "https://huggingface.co/jgkawell/jarvis/resolve/main/en/en_GB/jarvis/medium/jarvis-medium.onnx.json"

echo "=== Verifying files ==="
MODEL_SIZE=$(stat -c%s jarvis-medium.onnx)
echo "Model file size: $MODEL_SIZE bytes"

if [ "$MODEL_SIZE" -lt 10000000 ]; then
  echo "ERROR: Model file too small (expected ~60MB)"
  exit 1
fi

echo "Config file:"
head -c 200 jarvis-medium.onnx.json

echo ""
echo "=== Starting application ==="
cd ..
exec python main.py