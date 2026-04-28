#!/bin/bash


DEFAULT_WALLPAPER_DIR="/home/milesdredd/Pictures/wallpapers/"
INDEX_FILE="/home/milesdredd/.config/niri/.wallpaper_index"


# Transitions: none, simple, fade, left, right, top, bottom, wipe, wave, grow, center, any, outer, random
TRANSITION_TYPE="grow"

TRANSITION_DURATION=2

TRANSITION_FPS=50

# --- Argument Parsing ---
WALLPAPER_DIR="$DEFAULT_WALLPAPER_DIR"
DIRECTION="n" # Default to 'next'


for arg in "$@"; do
  if [[ -d "$arg" ]]; then
    # Argument is a directory that exists
    WALLPAPER_DIR="$arg"
  elif [[ "$arg" == "p" ]]; then
    # Argument is 'p' for previous
    DIRECTION="p"
  fi
done

# --- Pre-flight Checks ---
# Check if the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory '$WALLPAPER_DIR' not found."
    exit 1
fi

# Check if swww is installed
if ! command -v swww &> /dev/null; then
    echo "Error: 'swww' command not found. Please install it first."
    exit 1
fi

# --- Main Logic ---
# Find all image files (jpg, jpeg, png, gif, webp) in the directory and sort them
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | sort)

TOTAL_WALLPAPERS=${#WALLPAPERS[@]}

# Check if any wallpapers were found
if [ "$TOTAL_WALLPAPERS" -eq 0 ]; then
    echo "No image files found in '$WALLPAPER_DIR'."
    exit 1
fi

# Load the saved index, or default to -1 for the first run
CURRENT_INDEX=-1
if [ -f "$INDEX_FILE" ]; then
    CURRENT_INDEX=$(cat "$INDEX_FILE")
fi

# Ensure the index is a number and within a valid range
if ! [[ "$CURRENT_INDEX" =~ ^[0-9]+$ ]] || [ "$CURRENT_INDEX" -lt 0 ] || [ "$CURRENT_INDEX" -ge "$TOTAL_WALLPAPERS" ]; then
    CURRENT_INDEX=-1
fi

# Determine the next index based on direction
if [[ $DIRECTION == "p" ]]; then
    # Previous wallpaper (cycles)
    NEXT_INDEX=$(( (CURRENT_INDEX - 1 + TOTAL_WALLPAPERS) % TOTAL_WALLPAPERS ))
else
    # Next wallpaper (cycles)
    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL_WALLPAPERS ))
fi

# --- Execution ---
# Build swww options
SWWW_OPTS="--transition-type $TRANSITION_TYPE --transition-duration $TRANSITION_DURATION --transition-fps $TRANSITION_FPS"

# Set the new wallpaper
swww img $SWWW_OPTS "${WALLPAPERS[$NEXT_INDEX]}"

# Save the new index
echo "$NEXT_INDEX" > "$INDEX_FILE"
