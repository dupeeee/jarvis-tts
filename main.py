from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
import piper
import tempfile
import os
import uuid
from pathlib import Path
import logging
import hashlib

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Jarvis TTS API",
    description="Text-to-Speech API using Piper TTS with JARVIS voice",
    version="1.0.0"
)

# Cache directory
CACHE_DIR = Path("cache")
CACHE_DIR.mkdir(exist_ok=True)

# Model paths
MODEL_PATH = "models/jarvis-medium.onnx"
CONFIG_PATH = "models/jarvis-medium.onnx.json"

# Global model variable
model = None

@app.on_event("startup")
async def startup_event():
    """Load the Piper TTS model on startup"""
    global model
    logger.info("Loading Piper TTS model...")
    try:
        model = piper.PiperVoice.load(MODEL_PATH)
        logger.info("Model loaded successfully!")
    except Exception as e:
        logger.error(f"Failed to load model: {str(e)}")
        raise

class TTSRequest(BaseModel):
    text: str
    voice: str = "jarvis"
    format: str = "wav"  # wav or mp3

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Jarvis TTS API",
        "status": "running",
        "endpoints": {
            "POST /tts": "Convert text to speech",
            "GET /health": "Health check",
            "GET /cache/stats": "Cache statistics"
        }
    }

@app.post("/tts")
async def text_to_speech(request: TTSRequest):
    """Convert text to speech using Piper TTS"""
    try:
        # Validate text length
        if len(request.text) > 1000:
            raise HTTPException(status_code=400, detail="Text too long (max 1000 characters)")
        
        # Validate format
        if request.format not in ["wav", "mp3"]:
            raise HTTPException(status_code=400, detail="Format must be 'wav' or 'mp3'")
        
        # Generate cache key
        text_hash = hashlib.md5(request.text.encode()).hexdigest()
        cache_key = f"{request.voice}_{text_hash}"
        cache_file = CACHE_DIR / f"{cache_key}.{request.format}"
        
        # Check cache
        if cache_file.exists():
            logger.info(f"Cache hit: {cache_file.name}")
            return FileResponse(
                cache_file,
                media_type=f"audio/{request.format}",
                headers={"X-Cache": "HIT"}
            )
        
        # Generate audio
        logger.info(f"Synthesizing: {request.text[:50]}...")
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            temp_wav = f.name
        
        with open(temp_wav, "wb") as wav_file:
            model.synthesize_wav(request.text, wav_file)
        
        # Convert to MP3 if requested
        if request.format == "mp3":
            try:
                from pydub import AudioSegment
                audio = AudioSegment.from_wav(temp_wav)
                audio.export(cache_file, format="mp3", bitrate="128k")
                os.unlink(temp_wav)
            except ImportError:
                logger.warning("pydub not available, falling back to WAV")
                os.rename(temp_wav, cache_file)
        else:
            os.rename(temp_wav, cache_file)
        
        logger.info(f"Generated: {cache_file.name}")
        return FileResponse(
            cache_file,
            media_type=f"audio/{request.format}",
            headers={"X-Cache": "MISS"}
        )
        
    except Exception as e:
        logger.error(f"TTS error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model": "jarvis",
        "model_loaded": model is not None
    }

@app.get("/cache/stats")
async def cache_stats():
    """Get cache statistics"""
    cache_files = list(CACHE_DIR.glob("*.*"))
    total_size = sum(f.stat().st_size for f in cache_files)
    
    return {
        "cached_files": len(cache_files),
        "total_size_bytes": total_size,
        "total_size_mb": round(total_size / (1024 * 1024), 2)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
