# flac_to_aiff bash script
Simple Bash Script to Convert Flac music File into AIFF

For this script to work you need to have installed the following packages:
- ffmpeg  (https://ffmpeg.org/)

## Usage
For more convenience you can add the script to your PATH variable, so you can use it from anywhere in your system.
Or you can also copy/paste it under /usr/local/bin/ (Linux/Mac) or C:\Windows\System32\ (Windows) to use it from anywhere in your system.

## What does this script do?
This script will convert all the flac files in the current directory into aiff files and save them in a new folder called "flac_to_aiff" in the current directory.
It will walk all the subdirectories of the current user folder looking for flac files to convert.

## Next steps
- Add a parameter to specify if we want to delete the original flac files after the conversion
- Add a parameter to specify if we want to create a new folder. Maybe no need to separate the converted files from the original ones especially if we want to delete the flac files after the conversion.

## Pre-requisites
### ffmpeg
#### Linux
- Debian/Ubuntu: `sudo apt-get install ffmpeg`
- Fedora: `sudo dnf install ffmpeg`
- Arch Linux: `sudo pacman -S ffmpeg`

#### Mac
- Homebrew: `brew install ffmpeg`

#### Windows
- Download the latest version from https://ffmpeg.org/download.html
- Extract the zip file
- Add the bin folder to your PATH variable
- Restart your computer

