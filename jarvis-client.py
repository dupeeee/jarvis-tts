#!/usr/bin/env python3
"""
Jarvis TTS Client for Raspberry Pi
Simple script to convert text to speech using the JARVIS API
"""

import requests
import os
import sys
import time

# Configuration
API_URL = "https://jarvis-tts.onrender.com/tts"
OUTPUT_FILE = "jarvis_output.wav"
TIMEOUT = 60  # seconds

def speak(text, format="wav"):
    """
    Convert text to speech and play it
    
    Args:
        text (str): Text to convert to speech
        format (str): Audio format ('wav' or 'mp3')
    """
    try:
        print(f"🎙️  JARVIS: {text}")
        print(f"⏳ Generating audio...")
        
        start_time = time.time()
        
        response = requests.post(
            API_URL,
            json={"text": text, "format": format},
            timeout=TIMEOUT
        )
        
        elapsed_time = time.time() - start_time
        
        if response.status_code == 200:
            # Save audio file
            with open(OUTPUT_FILE, "wb") as f:
                f.write(response.content)
            
            file_size = os.path.getsize(OUTPUT_FILE) / 1024  # KB
            
            print(f"✅ Audio generated in {elapsed_time:.1f}s")
            print(f"📁 File: {OUTPUT_FILE} ({file_size:.1f} KB)")
            print(f"🔊 Playing audio...")
            
            # Play audio
            if sys.platform == "linux":
                # Try different audio players
                players = ["aplay", "paplay", "ffplay", "mpg123"]
                for player in players:
                    if os.system(f"which {player} > /dev/null 2>&1") == 0:
                        if player == "ffplay":
                            os.system(f"ffplay -autoexit -nodisp -loglevel quiet {OUTPUT_FILE}")
                        else:
                            os.system(f"{player} {OUTPUT_FILE}")
                        break
                else:
                    print("⚠️  No audio player found. Install 'alsa-utils' or 'ffmpeg'")
                    print(f"📁 Audio saved to: {OUTPUT_FILE}")
            else:
                print(f"📁 Audio saved to: {OUTPUT_FILE}")
                print("⚠️  Auto-play not supported on this platform")
            
            # Clean up
            if os.path.exists(OUTPUT_FILE):
                os.remove(OUTPUT_FILE)
                
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.Timeout:
        print(f"❌ Timeout: Request took longer than {TIMEOUT} seconds")
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Could not connect to the API")
        print("💡 Make sure the API is deployed and accessible")
    except Exception as e:
        print(f"❌ Exception: {str(e)}")

def main():
    """Main function"""
    print("=" * 50)
    print("🤖 JARVIS TTS Client")
    print("=" * 50)
    print()
    
    # Check if text is provided as argument
    if len(sys.argv) > 1:
        text = " ".join(sys.argv[1:])
        speak(text)
    else:
        # Interactive mode
        print("Enter text to speak (or 'quit' to exit):")
        print()
        
        while True:
            try:
                text = input("🎙️  You: ").strip()
                
                if text.lower() in ["quit", "exit", "q"]:
                    print("👋 Goodbye!")
                    break
                
                if text:
                    speak(text)
                    print()
                    
            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except EOFError:
                print("\n👋 Goodbye!")
                break

if __name__ == "__main__":
    main()
