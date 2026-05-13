FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .

# Create models and cache directories
RUN mkdir -p models cache

# Download model files during build
RUN echo "Downloading JARVIS TTS model..." && \
    curl -L -o models/jarvis-medium.onnx "https://huggingface.co/jgkawell/jarvis/resolve/main/en/jarvis-medium.onnx" && \
    curl -L -o models/jarvis-medium.onnx.json "https://huggingface.co/jgkawell/jarvis/resolve/main/en/jarvis-medium.onnx.json" && \
    echo "Model files downloaded successfully"

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
