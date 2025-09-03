# FLAC to AIFF Converter

A simple yet powerful set of scripts to convert FLAC music files to AIFF format, preserving album artwork and maintaining maximum audio quality. Supports macOS, Linux, and Windows.

## Features

-   **Lossless Conversion**: Converts FLAC files to uncompressed AIFF (`pcm_s16be`) for zero loss in audio quality.
-   **Artwork Preservation**: Retains embedded album artwork during conversion.
-   **Recursive Search**: Automatically finds and converts all `.flac` files in the current directory and its subdirectories.
-   **File Management**: Offers options to either overwrite the original files or keep them and save converted files in a separate directory.
-   **Cross-Platform**: Provides a `flactoaiff.sh` for Linux/macOS and a `flactoaiff.bat` for Windows.

## Prerequisites

Before using this script, you must have `ffmpeg` installed and accessible in your system's PATH.

-   **Official Website**: [ffmpeg.org](https://ffmpeg.org/)

### Installation

#### macOS (using [Homebrew](https://brew.sh/))

```bash
brew install ffmpeg
```

#### Linux

-   **Debian/Ubuntu**: `sudo apt-get update && sudo apt-get install ffmpeg`
-   **Fedora**: `sudo dnf install ffmpeg`
-   **Arch Linux**: `sudo pacman -S ffmpeg`

#### Windows

1.  Download the latest "release essentials" build from [gyan.dev](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip).
2.  Unzip the file to a permanent location on your computer (e.g., `C:\Program Files\ffmpeg`).
3.  Add the `bin` subfolder from that location (e.g., `C:\Program Files\ffmpeg\bin`) to the Windows PATH environment variable. ([How-to guide](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/))

---

## Usage

### For Linux & macOS

1.  **Make the script executable** (you only need to do this once):
    ```bash
    chmod +x script/flactoaiff.sh
    ```
2.  **Run the script** from the directory containing your FLAC files:
    -   **To convert and replace original files**:
        ```bash
        /path/to/script/flactoaiff.sh
        ```
    -   **To keep original files**:
        ```bash
        /path/to/script/flactoaiff.sh -k
        ```
        This saves the `.aiff` versions in a `flac_to_aiff` subfolder next to the original file.

### For Windows

Run the script from the `cmd` prompt or PowerShell, starting from the directory containing your FLAC files:

-   **To convert and replace original files**:
    ```powershell
    path\to\script\flactoaiff.bat
    ```
-   **To keep original files**:
    ```powershell
    path\to\script\flactoaiff.bat -k
    ```
    This saves the `.aiff` versions in a `flac_to_aiff` subfolder next to the original file. You can use `/k` instead of `-k`.

---

## Python Script Version (`flactoaiff.py`)

A Python-based version of the converter is also available. It offers the same functionality as the shell scripts but with a rich, interactive progress bar.

### Prerequisites

In addition to `ffmpeg`, you will need:
- Python 3.6+
- The `rich` library for the progress bar.

### Setup

1.  **Navigate** to the project directory in your terminal.
2.  **Install the required Python library** by running:
    ```bash
    pip install -r requirements.txt
    ```

### Usage

Run the script from the root directory containing your FLAC files.

-   **To convert and replace original files**:
    ```bash
    python3 script/flactoaiff.py
    ```
-   **To keep original files** (saves AIFF files in a `flac_to_aiff` subfolder):
    ```bash
    python3 script/flactoaiff.py -k
    ```

---

## Making the Script Globally Accessible (Optional)

### For Linux & macOS

Copy the script to `/usr/local/bin` to run it from any directory by just typing `flactoaiff`.

```bash
sudo cp script/flactoaiff.sh /usr/local/bin/flactoaiff
sudo chmod +x /usr/local/bin/flactoaiff
```

### For Windows

The easiest way is to add the `script` folder's full path to your system's PATH environment variable. Once you do this and restart your terminal, you can run `flactoaiff.bat` from any directory.

## How It Works

The script recursively scans the specified directory for files with the `.flac` extension. For each file found, it uses `ffmpeg` with the following key parameters:

-   `-i "$FLAC_FILE_NAME"`: Specifies the input file.
-   `-map 0`: Selects all streams from the input (audio, video, attachments).
-   `-c:v copy`: Copies the video stream (album art) without re-encoding.
-   `-c:a pcm_s16be`: Sets the audio codec to 16-bit PCM for lossless AIFF.
-   `-write_id3v2 1`: Ensures ID3v2 metadata tags are written to the new file.
