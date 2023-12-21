#!/bin/bash
echo "This script will convert all flac files to aiff files"
# walk directory tree and filter for files with extension flac
walk_flac () {
    shopt -s nullglob dotglob
    for pathname in "$1"/*; do
        if [ -d "$pathname" ]; then
            walk_flac "$pathname"
        else
            if [[ "$pathname" == *.flac ]]; then
                FLAC_FILE_NAME="$pathname"
                # create subfolder named aiff if it doesn't exist
                mkdir -p "$1/flac_to_aiff"
                # create aiff file with same name as flac file
                AIFF_FILE_NAME="${FLAC_FILE_NAME%.*}.aiff"
                # change aiff path to add subfolder flac_to_aiff
                AIFF_FILE_NAME="$1/flac_to_aiff/${AIFF_FILE_NAME##*/}"
                echo "Converting $FLAC_FILE_NAME to $AIFF_FILE_NAME"
                # using ffmpeg to convert flac to aiff and write id3 tags
                # -loglevel quiet to suppress output
                # -n to not overwrite existing files
                ffmpeg -loglevel quiet -n -i "$FLAC_FILE_NAME" -write_id3v2 1 -c:v copy "$AIFF_FILE_NAME"
            fi
        fi
    done
}
BASEDIR=${PWD}
walk_flac "$BASEDIR"
