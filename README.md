# Jarvis TTS API - Render Deployment Guide

A cloud-based Text-to-Speech API using Piper TTS with the JARVIS voice, deployed on Render.

## 🚀 Quick Start

### Prerequisites

- A [Render](https://render.com) account (free tier)
- A [GitHub](https://github.com) account
- The JARVIS TTS model files from Hugging Face

## 📁 Project Structure

```
jarvis-tts/
├── main.py              # FastAPI application
├── requirements.txt     # Python dependencies
├── Dockerfile          # Docker configuration
├── render.yaml         # Render deployment config
├── .gitignore          # Git ignore rules
├── models/             # Model files (not in git)
│   ├── jarvis-medium.onnx
│   └── jarvis-medium.onnx.json
└── cache/              # Audio cache (not in git)
```

## 📥 Step 1: Download the Model Files

1. Go to https://huggingface.co/jgkawell/jarvis/tree/main/en
2. Download these files:
   - `jarvis-medium.onnx`
   - `jarvis-medium.onnx.json`
3. Create a `models` folder in your project
4. Place both files in the `models` folder

```bash
mkdir models
# Copy the downloaded files to models/
```

## 🌐 Step 2: Push to GitHub

1. Create a new repository on GitHub (name it `jarvis-tts`)
2. Initialize git in your project folder:

```bash
cd jarvis-tts
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/jarvis-tts.git
git push -u origin main
```

## 🎨 Step 3: Deploy to Render

### Option A: Using render.yaml (Recommended)

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Render will automatically detect `render.yaml`
5. Click **"Create Web Service"**

### Option B: Manual Configuration

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Configure:
   - **Name:** `jarvis-tts`
   - **Region:** Oregon (closest to South Africa)
   - **Branch:** `main`
   - **Runtime:** Docker
   - **Instance Type:** Free
   - **Environment Variables:** (none needed)
5. Click **"Create Web Service"**

## ⚠️ Important: Upload Model Files

Render's free tier doesn't support persistent storage, so we need to upload the model files manually:

### Method 1: Using Render Shell (Recommended)

1. Go to your Render service dashboard
2. Click **"Shell"** tab
3. Run these commands:

```bash
cd /app
mkdir -p models
# Upload your model files using the file upload feature
# or use wget if you have them hosted somewhere
```

### Method 2: Using Environment Variables (For Small Configs)

If the `.onnx.json` file is small, you can:

1. Copy the contents of `jarvis.onnx.json`
2. Add it as an environment variable in Render:
   - Key: `MODEL_CONFIG`
   - Value: (paste the JSON content)
3. Update `main.py` to read from environment variable

### Method 3: Use a Public URL

1. Upload your model files to a public URL (GitHub Releases, etc.)
2. Add a startup script to download them:

```python
# Add to main.py startup
import os
import requests

def download_model():
    if not os.path.exists("models/jarvis.onnx"):
        os.makedirs("models", exist_ok=True)
        # Download from your public URL
        response = requests.get("YOUR_PUBLIC_URL/jarvis.onnx")
        with open("models/jarvis.onnx", "wb") as f:
            f.write(response.content)
```

## 🧪 Step 4: Test the API

Once deployed, you'll get a URL like: `https://jarvis-tts.onrender.com`

### Test Endpoints:

```bash
# Health check
curl https://jarvis-tts.onrender.com/health

# Generate speech
curl -X POST https://jarvis-tts.onrender.com/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, sir. Systems are operational."}' \
  --output output.wav

# Get cache stats
curl https://jarvis-tts.onrender.com/cache/stats
```

## 📱 Step 5: Use from Your Pi 1

Create a Python script on your Pi:

```python
import requests
import os

API_URL = "https://jarvis-tts.onrender.com/tts"

def speak(text):
    """Convert text to speech and play it"""
    try:
        response = requests.post(
            API_URL,
            json={"text": text, "format": "wav"},
            timeout=30
        )
        
        if response.status_code == 200:
            # Save audio file
            with open("output.wav", "wb") as f:
                f.write(response.content)
            
            # Play audio (using aplay on Pi)
            os.system("aplay output.wav")
            print(f"✓ Played: {text[:50]}...")
        else:
            print(f"✗ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"✗ Exception: {str(e)}")

# Usage
speak("Hello, sir. Systems are operational.")
speak("The weather is currently clear with a temperature of 22 degrees.")
```

## 🔧 Configuration Options

### Environment Variables

You can add these in Render's dashboard:

- `PORT`: Port number (default: 8000)
- `MODEL_PATH`: Path to model file (default: models/jarvis.onnx)
- `CONFIG_PATH`: Path to config file (default: models/jarvis.onnx.json)

### Request Parameters

```json
{
  "text": "Text to convert to speech",
  "voice": "jarvis",           // Currently only jarvis supported
  "format": "wav"              // "wav" or "mp3"
}
```

## 📊 Monitoring

### View Logs

1. Go to your Render service dashboard
2. Click **"Logs"** tab
3. View real-time logs

### Check Health

```bash
curl https://jarvis-tts.onrender.com/health
```

### Cache Statistics

```bash
curl https://jarvis-tts.onrender.com/cache/stats
```

## ⚡ Performance Tips

1. **Caching:** The API automatically caches generated audio
2. **Cold Starts:** Render free tier has ~50 second cold starts
3. **Timeout:** Requests timeout after 30 seconds
4. **Rate Limiting:** Consider adding rate limiting for production use

## 🐛 Troubleshooting

### Service won't start

- Check the logs in Render dashboard
- Ensure model files are uploaded correctly
- Verify Docker build completed successfully

### Model not found

- Ensure model files are in `/app/models/` directory
- Check file names match exactly: `jarvis.onnx` and `jarvis.onnx.json`

### Slow response times

- First request after deployment will be slow (cold start)
- Subsequent requests should be faster
- Consider upgrading to paid tier for better performance

### Out of memory

- Render free tier has 512MB RAM limit
- Piper TTS + model might be tight
- Consider using a smaller model or upgrading to paid tier

## 🔄 Updating the API

1. Make changes to your code
2. Commit and push to GitHub
3. Render will automatically redeploy

```bash
git add .
git commit -m "Update API"
git push
```

## 📈 Scaling Up

If you need better performance:

1. **Upgrade to Starter ($7/month):**
   - 512MB → 1GB RAM
   - Better CPU performance
   - Faster cold starts

2. **Add a CDN:**
   - Use Cloudflare or similar
   - Cache audio responses globally

3. **Use a database:**
   - Store cache in Redis
   - Persistent storage across restarts

## 🔒 Security Considerations

For production use, consider adding:

1. **API Key Authentication:**
```python
from fastapi import Header, HTTPException

API_KEY = "your-secret-key"

@app.post("/tts")
async def text_to_speech(request: TTSRequest, x_api_key: str = Header(...)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API key")
    # ... rest of the code
```

2. **Rate Limiting:**
```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/tts")
@limiter.limit("10/minute")
async def text_to_speech(request: TTSRequest):
    # ... rest of the code
```

## 📞 Support

If you encounter issues:

1. Check Render logs
2. Verify model files are uploaded
3. Test API endpoints manually
4. Check Render status page: https://status.render.com

## 🎉 You're All Set!

Your Jarvis TTS API is now running on Render and accessible from anywhere!

From your Pi 1, you can now:
```python
speak("Hello, sir. The system is online and ready.")
```
