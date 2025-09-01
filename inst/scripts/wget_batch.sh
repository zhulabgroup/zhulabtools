#!/bin/bash

# Configuration: Define all file paths and names here
URL_FILE="envidatS3paths.txt"   # File containing the list of URLs to download
LOG_FILE="download_log.txt"     # Log file to record the download process
DEST_DIR="../"                  # Destination directory for downloads

# Ensure the URL file exists
if [ ! -f "$URL_FILE" ]; then
    echo "URL file not found: $URL_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

# Use wget to download files listed in the URL file, storing all files in the specified directory
(
    wget --no-host-directories --input-file="$URL_FILE" -nc -v -P "$DEST_DIR"
) >> "$LOG_FILE" 2>&1 &

echo "Download script is running in the background. Check $LOG_FILE for progress."
