#!/bin/bash

# Download JARVIS TTS Model Files
# This script downloads the model files from Hugging Face

echo "📥 Downloading JARVIS TTS model files..."

# Create models directory
mkdir -p models

# Download model files
echo "Downloading jarvis-medium.onnx (this may take a while - ~2GB)..."
curl -L -o models/jarvis-medium.onnx "https://huggingface.co/jgkawell/jarvis/resolve/main/en/jarvis-medium.onnx"

echo "Downloading jarvis-medium.onnx.json..."
curl -L -o models/jarvis-medium.onnx.json "https://huggingface.co/jgkawell/jarvis/resolve/main/en/jarvis-medium.onnx.json"

echo "✅ Download complete!"
echo ""
echo "Files downloaded:"
ls -lh models/

echo ""
echo "✨ You're ready to proceed to Step 2!"
