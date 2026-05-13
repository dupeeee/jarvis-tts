# 🎯 Jarvis TTS API - Deployment Checklist

## ✅ Pre-Deployment Checklist

### Files Created
- [x] `main.py` - FastAPI application
- [x] `requirements.txt` - Python dependencies
- [x] `Dockerfile` - Docker configuration
- [x] `render.yaml` - Render deployment config
- [x] `.gitignore` - Git ignore rules
- [x] `README.md` - Project documentation
- [x] `SETUP-GUIDE.md` - Complete setup guide
- [x] `download-model.sh` - Model download script
- [x] `quick-start.sh` - Quick start script
- [x] `jarvis-client.py` - Pi client script

### Model Files
- [ ] `models/jarvis-medium.onnx` (~2GB)
- [ ] `models/jarvis-medium.onnx.json` (~15KB)

**Note:** These will be auto-downloaded during Docker build, but you can download them locally first using `./download-model.sh`

---

## 🚀 Deployment Steps

### Step 1: Prepare Your Code
```bash
cd /home/clint/.picoclaw/workspace/jarvis-tts

# Verify all files exist
ls -la

# Test locally (optional)
./quick-start.sh
```

### Step 2: Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: `jarvis-tts`
3. Description: `JARVIS Text-to-Speech API`
4. Make it **Public**
5. Click **Create repository**

### Step 3: Push to GitHub
```bash
# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: JARVIS TTS API"

# Rename branch to main
git branch -M main

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/jarvis-tts.git

# Push to GitHub
git push -u origin main
```

### Step 4: Deploy to Render
1. Go to https://dashboard.render.com
2. Click **"New +"** → **"Web Service"**
3. Connect your `jarvis-tts` repository
4. Configure:
   - **Name:** `jarvis-tts`
   - **Region:** Oregon
   - **Branch:** `main`
   - **Runtime:** Docker
   - **Instance Type:** Free
5. Click **"Create Web Service"**

### Step 5: Monitor Deployment
- Watch the **Logs** tab
- Look for: `Model files downloaded successfully`
- Wait for: `Application startup complete`

**⏱️ Expected time:** 10-15 minutes (first deployment)

---

## 🧪 Post-Deployment Testing

### Test 1: Health Check
```bash
curl https://jarvis-tts.onrender.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "model": "jarvis",
  "model_loaded": true
}
```

### Test 2: Generate Speech
```bash
curl -X POST https://jarvis-tts.onrender.com/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, sir. Systems are operational."}' \
  --output test.wav
```

### Test 3: Play Audio
```bash
aplay test.wav
```

### Test 4: API Documentation
Visit: https://jarvis-tts.onrender.com/docs

---

## 📱 Raspberry Pi Integration

### Option 1: Use the Client Script
```bash
# Copy jarvis-client.py to your Pi
scp jarvis-client.py pi@your-pi-ip:~/

# On your Pi
python3 jarvis-client.py "Hello, sir. Systems are operational."
```

### Option 2: Simple Python Script
```python
import requests
import os

API_URL = "https://jarvis-tts.onrender.com/tts"

def speak(text):
    response = requests.post(API_URL, json={"text": text})
    with open("output.wav", "wb") as f:
        f.write(response.content)
    os.system("aplay output.wav")

speak("Hello, sir. The system is online and ready.")
```

---

## 🔧 Troubleshooting

### Issue: Deployment Fails
**Check:**
- Render logs for errors
- GitHub repository is public
- All files are committed

### Issue: Model Not Found
**Check:**
- Logs show "Model files downloaded successfully"
- Model files exist in `/app/models/`
- File names match exactly

### Issue: Slow Response
**Normal:**
- First request: 30-60 seconds (cold start)
- Subsequent requests: 5-15 seconds

**If consistently slow:**
- Consider upgrading to paid tier
- Check Render status page

### Issue: Out of Memory
**Symptoms:** Service crashes or restarts

**Solutions:**
- Free tier has 512MB RAM limit
- Model is ~2GB, might be tight
- Upgrade to Starter tier ($7/month)

---

## 📊 Monitoring

### View Logs
1. Go to Render dashboard
2. Click **"Logs"** tab
3. View real-time logs

### Check Statistics
```bash
curl https://jarvis-tts.onrender.com/cache/stats
```

### Health Check
```bash
curl https://jarvis-tts.onrender.com/health
```

---

## 🔄 Updates

### Update the API
```bash
# Make changes locally
git add .
git commit -m "Update: your changes"
git push
```

Render will automatically redeploy!

### Rollback
1. Go to Render dashboard
2. Click **"Deployments"** tab
3. Find previous successful deployment
4. Click **"Redeploy"**

---

## 🎉 Success Criteria

You'll know everything is working when:

- [ ] GitHub repository is created and pushed
- [ ] Render service is deployed
- [ ] Health check returns `{"status": "healthy"}`
- [ ] TTS endpoint generates audio files
- [ ] Audio plays correctly on your Pi
- [ ] API documentation is accessible

---

## 📞 Quick Reference

### URLs
- **GitHub:** https://github.com/YOUR_USERNAME/jarvis-tts
- **Render:** https://dashboard.render.com
- **API:** https://jarvis-tts.onrender.com
- **Docs:** https://jarvis-tts.onrender.com/docs

### Commands
```bash
# Local testing
python main.py

# Download models
./download-model.sh

# Quick start
./quick-start.sh

# Push to GitHub
git push

# Test API
curl https://jarvis-tts.onrender.com/health
```

---

## 🚀 Next Steps

Once deployed:

1. **Test from your Pi** - Use `jarvis-client.py`
2. **Integrate with home automation** - Add to your existing scripts
3. **Build a web interface** - Create a simple UI
4. **Add more features** - Streaming, voice cloning, etc.

---

**Good luck with your deployment! 🎉**
