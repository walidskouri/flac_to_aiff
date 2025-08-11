#!/bin/bash
echo "This script will convert all flac files to aiff files"

# --- Configuration ---
# Set a clear variable for the keep option. This is safer than passing arguments.
KEEP_ORIGINAL_FILES=false
if [[ "$1" == "-k" ]]; then
  KEEP_ORIGINAL_FILES=true
fi

# Inform the user based on the variable set above
if [[ "$KEEP_ORIGINAL_FILES" == "true" ]]; then
  echo "Keep option activated: Original FLAC files will be preserved."
else
  echo "Default mode: Original FLAC files will be deleted after conversion."
fi
echo "----------------------------------------"

# --- Functions ---
# walk directory tree and filter for files with extension flac
walk_flac() {
  local current_dir="$1"

  for pathname in "$current_dir"/*; do
    if [ -d "$pathname" ]; then
      walk_flac "$pathname"
    else
      if [[ "$pathname" == *.flac ]]; then
        echo "Processing $pathname"
        FLAC_FILE_NAME="$pathname"
        AIFF_FILE_NAME="${FLAC_FILE_NAME%.*}.aiff"

        # If keeping files, modify the output path
        if [[ "$KEEP_ORIGINAL_FILES" == "true" ]]; then
          # Create the output directory inside the source file's directory
          local output_dir="$(dirname "$FLAC_FILE_NAME")/flac_to_aiff"
          mkdir -p "$output_dir"
          # Set the final AIFF file path
          AIFF_FILE_NAME="$output_dir/$(basename "$AIFF_FILE_NAME")"
        fi

        echo "Converting $FLAC_FILE_NAME to $AIFF_FILE_NAME"
        ffmpeg -loglevel quiet -n -i "$FLAC_FILE_NAME" -map 0 -c:v copy -c:a pcm_s16be -write_id3v2 1 "$AIFF_FILE_NAME"
        RC=$?

        if [[ "${RC}" -eq 0 ]]; then
          echo "Conversion successful"
          # Directly check the boolean flag before deleting
          if [[ "$KEEP_ORIGINAL_FILES" == "false" ]]; then
            echo "Deleting original file: $FLAC_FILE_NAME"
            rm "$FLAC_FILE_NAME"
          fi
        else
          echo "Conversion failed with error code: $RC"
        fi
        echo "Processing $pathname done !"
        echo "----------------------------------------"
      fi
    fi
  done
}

# --- Main Execution ---
BASEDIR=${PWD}
walk_flac "$BASEDIR"
