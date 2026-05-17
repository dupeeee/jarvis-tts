# 🚀 Jarvis TTS API - Complete Setup Guide

## 📋 Overview

This guide will walk you through setting up a cloud-based Text-to-Speech API using the JARVIS voice model, deployed on Render.

**What you'll get:**
- A FastAPI web service that converts text to speech
- The authentic JARVIS voice from Iron Man
- Accessible from anywhere via HTTP API
- Free hosting on Render

**Time required:** ~30 minutes

---

## 🎯 Prerequisites

Before we begin, make sure you have:

1. ✅ A [GitHub account](https://github.com) (free)
2. ✅ A [Render account](https://render.com) (free tier)
3. ✅ Basic command line knowledge
4. ✅ Internet connection

---

## 📁 Step 1: Project Structure

Your project folder should look like this:

```
jarvis-tts/
├── main.py              # FastAPI application
├── requirements.txt     # Python dependencies
├── Dockerfile          # Docker configuration
├── render.yaml         # Render deployment config
├── .gitignore          # Git ignore rules
├── README.md           # This file
├── download-model.sh   # Model download script
├── models/             # Model files (auto-downloaded)
│   ├── jarvis-medium.onnx
│   └── jarvis-medium.onnx.json
└── cache/              # Audio cache (auto-created)
```

**✅ Status:** All files are already created for you!

---

## 📥 Step 2: Download Model Files (Optional)

The Dockerfile will automatically download the model files during deployment. However, if you want to test locally first:

### Option A: Automatic Download (Recommended)

```bash
cd /home/clint/.picoclaw/workspace/jarvis-tts
./download-model.sh
```

This will download:
- `jarvis-medium.onnx` (~2GB)
- `jarvis-medium.onnx.json` (~15KB)

### Option B: Manual Download

1. Visit: https://huggingface.co/jgkawell/jarvis/tree/main/en/en_GB/jarvis/medium
2. Download these files:
   - `jarvis-medium.onnx`
   - `jarvis-medium.onnx.json`
3. Place them in the `models/` folder

**⏱️ Note:** The model file is ~2GB, so this may take 10-30 minutes depending on your internet speed.

---

## 🧪 Step 3: Test Locally (Optional)

If you want to test the API before deploying:

### Install Dependencies

```bash
cd /home/clint/.picoclaw/workspace/jarvis-tts
pip install -r requirements.txt
```

### Run the API

```bash
python main.py
```

The API will start at: `http://localhost:8000`

### Test It

```bash
# Health check
curl http://localhost:8000/health

# Generate speech
curl -X POST http://localhost:8000/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, sir. Systems are operational."}' \
  --output output.wav

# Play the audio
aplay output.wav
```

**✅ Status:** If this works, you're ready to deploy!

---

## 🌐 Step 4: Push to GitHub

### 4.1 Create a GitHub Repository

1. Go to https://github.com/new
2. Repository name: `jarvis-tts`
3. Description: `JARVIS Text-to-Speech API`
4. Make it **Public** (Render free tier requires public repos)
5. Click **Create repository**

### 4.2 Initialize Git and Push

```bash
cd /home/clint/.picoclaw/workspace/jarvis-tts

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: JARVIS TTS API"

# Rename branch to main
git branch -M main

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/jarvis-tts.git

# Push to GitHub
git push -u origin main
```

**🔑 Authentication:** If prompted for credentials:
- Use your GitHub username
- Use a **Personal Access Token** (not your password)
  - Create one at: https://github.com/settings/tokens
  - Select "repo" scope
  - Use the token as your password

**✅ Status:** Your code is now on GitHub!

---

## 🎨 Step 5: Deploy to Render

### 5.1 Create Render Account

1. Go to https://render.com
2. Click **"Sign Up"**
3. Sign up with GitHub (recommended)
4. Verify your email

### 5.2 Create a New Web Service

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. You'll see a list of your GitHub repositories
4. Find and select `jarvis-tts`
5. Click **"Connect"**

### 5.3 Configure the Service

Render will automatically detect your `render.yaml` file. Configure:

| Setting | Value |
|---------|-------|
| **Name** | `jarvis-tts` |
| **Region** | Oregon (closest to South Africa) |
| **Branch** | `main` |
| **Runtime** | Docker |
| **Instance Type** | Free |
| **Environment Variables** | (none needed) |

### 5.4 Deploy

Click **"Create Web Service"**

**⏱️ Deployment Time:**
- First deployment: ~10-15 minutes (downloads 2GB model)
- Subsequent deployments: ~2-3 minutes

### 5.5 Monitor Deployment

1. Watch the **Logs** tab for progress
2. Look for: `Model files downloaded successfully`
3. When you see `Application startup complete`, you're live!

**✅ Status:** Your API is now live on Render!

---

## 🧪 Step 6: Test Your Deployed API

Once deployed, you'll get a URL like:
`https://jarvis-tts.onrender.com`

### Test Endpoints

```bash
# Health check
curl https://jarvis-tts.onrender.com/health

# Generate speech
curl -X POST https://jarvis-tts.onrender.com/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, sir. Systems are operational."}' \
  --output output.wav

# Play the audio
aplay output.wav

# Cache statistics
curl https://jarvis-tts.onrender.com/cache/stats
```

### API Documentation

Visit: `https://jarvis-tts.onrender.com/docs`

This will show you the interactive Swagger UI where you can test all endpoints.

---

## 📱 Step 7: Use from Your Pi 1

Create a Python script on your Raspberry Pi:

```python
import requests
import os

API_URL = "https://jarvis-tts.onrender.com/tts"

def speak(text):
    """Convert text to speech and play it"""
    try:
        print(f"🎙️  Generating: {text[:50]}...")
        
        response = requests.post(
            API_URL,
            json={"text": text, "format": "wav"},
            timeout=60  # 60 second timeout
        )
        
        if response.status_code == 200:
            # Save audio file
            with open("output.wav", "wb") as f:
                f.write(response.content)
            
            # Play audio (using aplay on Pi)
            os.system("aplay output.wav")
            print(f"✅ Played: {text[:50]}...")
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Exception: {str(e)}")

# Usage examples
speak("Hello, sir. Systems are operational.")
speak("The weather is currently clear with a temperature of 22 degrees.")
speak("All systems are functioning within normal parameters.")
```

Save this as `speak.py` and run:

```bash
python speak.py
```

---

## 🔧 Advanced Configuration

### Environment Variables

You can add these in Render's dashboard:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 8000 | Port number |
| `MODEL_PATH` | models/jarvis-medium.onnx | Path to model file |
| `CONFIG_PATH` | models/jarvis-medium.onnx.json | Path to config file |

### Request Parameters

```json
{
  "text": "Text to convert to speech",
  "voice": "jarvis",           // Currently only jarvis supported
  "format": "wav"              // "wav" or "mp3"
}
```

### Response Headers

- `X-Cache: HIT` - Audio was cached (faster response)
- `X-Cache: MISS` - Audio was generated (slower response)

---

## 📊 Monitoring & Debugging

### View Logs

1. Go to your Render service dashboard
2. Click **"Logs"** tab
3. View real-time logs

### Common Issues

#### Service won't start

**Symptoms:** Service shows "Deploy failed" or keeps restarting

**Solutions:**
- Check the logs in Render dashboard
- Ensure model files downloaded successfully
- Verify Docker build completed

#### Model not found

**Symptoms:** Error "Failed to load model"

**Solutions:**
- Check logs for download errors
- Verify model files exist in `/app/models/`
- File names must match exactly

#### Slow response times

**Symptoms:** First request takes 30+ seconds

**Solutions:**
- First request after deployment is slow (cold start)
- Subsequent requests should be faster
- Consider upgrading to paid tier for better performance

#### Out of memory

**Symptoms:** Service crashes or restarts frequently

**Solutions:**
- Render free tier has 512MB RAM limit
- Model is ~2GB, might be tight
- Consider upgrading to Starter tier ($7/month)

---

## 🔄 Updating the API

### Make Changes

1. Edit your code locally
2. Test locally if needed
3. Commit and push to GitHub

```bash
git add .
git commit -m "Update: your change description"
git push
```

Render will automatically redeploy!

### Rollback

If something breaks:

1. Go to Render dashboard
2. Click **"Deployments"** tab
3. Find a previous successful deployment
4. Click **"Redeploy"**

---

## 📈 Scaling Up

### Free Tier Limitations

- 512MB RAM
- Shared CPU
- ~50 second cold starts
- 512MB disk space
- No persistent storage

### Upgrade Options

#### Starter ($7/month)

- 1GB RAM
- Better CPU
- Faster cold starts
- Better for production use

#### Standard ($25/month)

- 2GB RAM
- Dedicated CPU
- Even faster performance
- Recommended for heavy usage

---

## 🔒 Security Considerations

### Add API Key Authentication

For production use, add authentication:

```python
from fastapi import Header, HTTPException

API_KEY = "your-secret-key-here"

@app.post("/tts")
async def text_to_speech(request: TTSRequest, x_api_key: str = Header(None)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API key")
    # ... rest of the code
```

### Add Rate Limiting

Prevent abuse with rate limiting:

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/tts")
@limiter.limit("10/minute")
async def text_to_speech(request: TTSRequest):
    # ... rest of the code
```

---

## 🎉 You're All Set!

Your Jarvis TTS API is now running on Render and accessible from anywhere!

### Quick Reference

```bash
# API URL
https://jarvis-tts.onrender.com

# API Documentation
https://jarvis-tts.onrender.com/docs

# Health Check
curl https://jarvis-tts.onrender.com/health

# Generate Speech
curl -X POST https://jarvis-tts.onrender.com/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, sir."}' \
  --output output.wav
```

### From Your Pi

```python
speak("Hello, sir. The system is online and ready.")
speak("All systems are functioning within normal parameters.")
```

---

## 📞 Need Help?

### Resources

- [Render Documentation](https://render.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [Piper TTS GitHub](https://github.com/rhasspy/piper)

### Troubleshooting

1. Check Render logs
2. Verify model files are downloaded
3. Test API endpoints manually
4. Check [Render Status](https://status.render.com)

---

## 🚀 Next Steps

Now that your API is running, you can:

1. **Integrate with your Pi 1** - Use it in your home automation
2. **Build a web interface** - Create a simple web UI
3. **Add more voices** - Support multiple TTS models
4. **Add streaming** - Stream audio instead of downloading
5. **Add voice cloning** - Train custom voices

---

**Enjoy your JARVIS TTS API! 🎙️✨**
