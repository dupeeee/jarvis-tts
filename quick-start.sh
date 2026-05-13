#!/bin/bash

# Jarvis TTS API - Quick Start Script
# This script helps you get the API up and running quickly

set -e

echo "🚀 Jarvis TTS API - Quick Start"
echo "================================"
echo ""

# Check if we're in the right directory
if [ ! -f "main.py" ]; then
    echo "❌ Error: main.py not found. Please run this script from the jarvis-tts directory."
    exit 1
fi

echo "✅ Found project files"
echo ""

# Step 1: Download model files
echo "📥 Step 1: Downloading model files..."
if [ -f "models/jarvis-medium.onnx" ] && [ -f "models/jarvis-medium.onnx.json" ]; then
    echo "✅ Model files already exist. Skipping download."
else
    echo "Downloading model files (this may take 10-30 minutes)..."
    ./download-model.sh
fi
echo ""

# Step 2: Install dependencies
echo "📦 Step 2: Installing dependencies..."
pip install -r requirements.txt
echo ""

# Step 3: Test the API
echo "🧪 Step 3: Testing the API..."
echo "Starting the API in the background..."
python main.py &
API_PID=$!

# Wait for API to start
echo "Waiting for API to start..."
sleep 5

# Test health endpoint
echo "Testing health endpoint..."
curl -s http://localhost:8000/health | python -m json.tool
echo ""

# Test TTS endpoint
echo "Testing TTS endpoint..."
curl -X POST http://localhost:8000/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, sir. Systems are operational."}' \
  --output test-output.wav

if [ -f "test-output.wav" ]; then
    echo "✅ Audio file generated successfully!"
    echo "📁 File: test-output.wav"
    echo "📏 Size: $(du -h test-output.wav | cut -f1)"
    echo ""
    echo "🔊 Playing audio..."
    if command -v aplay &> /dev/null; then
        aplay test-output.wav
    elif command -v ffplay &> /dev/null; then
        ffplay -autoexit test-output.wav
    else
        echo "⚠️  No audio player found. Install 'alsa-utils' or 'ffmpeg' to play audio."
    fi
else
    echo "❌ Failed to generate audio file"
fi

# Cleanup
echo ""
echo "🧹 Cleaning up..."
kill $API_PID 2>/dev/null || true
rm -f test-output.wav

echo ""
echo "✨ Quick start complete!"
echo ""
echo "Next steps:"
echo "1. Test the API manually: python main.py"
echo "2. Visit http://localhost:8000/docs for API documentation"
echo "3. Follow SETUP-GUIDE.md to deploy to Render"
echo ""
