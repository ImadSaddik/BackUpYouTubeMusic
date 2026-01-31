#!/bin/bash

PROJECT_DIR="$HOME/Projects/BackUpYouTubeMusic"
MUSIC_DIR="$HOME/Music/YouTubeMusic/no_lyrics"
PLAYLIST_URL="https://www.youtube.com/playlist?list=PL22-qG2MGGhAr96FUEz9jv11sVx0nSZTY"

LOG_DIR="$PROJECT_DIR/logs"
mkdir -p "$LOG_DIR"
mkdir -p "$MUSIC_DIR"

# Redirect all stdout and stderr to the log file
LOG_FILE="$LOG_DIR/weekly_backup_$(date +%Y-%m-%d).log"
exec >> "$LOG_FILE" 2>&1

echo "--- Starting weekly backup at $(date) ---"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: Directory $PROJECT_DIR does not exist."
    exit 1
fi

CONDA_PATH="$HOME/anaconda3/etc/profile.d/conda.sh"
if [ -f "$CONDA_PATH" ]; then
    source "$CONDA_PATH"
    conda activate yt_downloader
else
    echo "Error: Conda profile script not found at $CONDA_PATH"
    exit 1
fi

cd "$PROJECT_DIR" || exit 1

echo "Running yt-dlp backup"

pip install --upgrade yt-dlp

yt-dlp -x --audio-format mp3 \
  --download-archive "$PROJECT_DIR/archive.txt" \
  --downloader aria2c \
  --downloader-args "aria2c:-x 16 -s 16 -k 1M" \
  -o "$MUSIC_DIR/%(title)s.%(ext)s" \
  "$PLAYLIST_URL"

echo "--- Backup job finished at $(date) ---"
exit 0
