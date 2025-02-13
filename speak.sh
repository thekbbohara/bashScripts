#!/bin/bash

# Check if a message is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 \"<text to synthesize>\""
  exit 1
fi

# Define the model and Piper binary paths
PIPER_BIN="$HOME/piper/build/piper"
MODEL_PATH="$HOME/piper/voices/en_GB/semaine/semaine-medium.onnx"

# Synthesize speech and play the output
echo "$1" | "$PIPER_BIN" --model "$MODEL_PATH" --output-raw |
  aplay -r 22050 -f S16_LE -t raw -
