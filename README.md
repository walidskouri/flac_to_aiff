# FLAC to AIFF Converter

A simple yet powerful Bash script to convert FLAC music files to AIFF format while preserving album artwork and maintaining maximum audio quality.

## Features

-   **Lossless Conversion**: Converts FLAC files to uncompressed AIFF (`pcm_s16be`) for zero loss in audio quality.
-   **Artwork Preservation**: Retains embedded album artwork during conversion.
-   **Recursive Search**: Automatically finds and converts all `.flac` files in the current directory and its subdirectories.
-   **File Management**: Offers options to either overwrite the original files or keep them and save converted files in a separate directory.
-   **Cross-Platform**: Works on any system with a Bash shell and `ffmpeg` (Linux, macOS, etc.).

## Prerequisites

Before using this script, you must have `ffmpeg` installed on your system.

-   **Website**: [ffmpeg.org](https://ffmpeg.org/)

### Installation

#### macOS (using [Homebrew](https://brew.sh/))

```bash
brew install ffmpeg
```

#### Linux

-   **Debian/Ubuntu**:
    ```bash
    sudo apt-get update && sudo apt-get install ffmpeg
    ```
-   **Fedora**:
    ```bash
    sudo dnf install ffmpeg
    ```
-   **Arch Linux**:
    ```bash
    sudo pacman -S ffmpeg
    ```

## Usage

1.  **Download the Script**:
    Clone or download the `flactoaiff.sh` script from this repository.

2.  **Make it Executable**:
    Open your terminal, navigate to the script's directory, and run:
    ```bash
    chmod +x script/flactoaiff.sh
    ```

3.  **Run the Script**:
    Execute the script from the directory containing your FLAC files.

    -   **To convert and replace original files**:
        ```bash
        ./script/flactoaiff.sh
        ```
        This will find all `.flac` files, convert them to `.aiff`, and delete the originals.

    -   **To keep original files**:
        ```bash
        ./script/flactoaiff.sh -k
        ```
        This will convert all `.flac` files, saving the new `.aiff` versions inside a `flac_to_aiff` subfolder created within the same directory as the original file. The original files will be left untouched.

### Making the Script Globally Accessible (Optional)

To run the script from any directory without typing the full path, you can add it to your system's `PATH`. Here are two common methods to do this.

#### Method 1: Copy to a System-Wide Directory (Recommended)

This method involves copying the script to a directory that is already in your `PATH`. `/usr/local/bin` is the standard location for user-installed executables on both macOS and Linux.

1.  **Copy the script and rename it**:
    This command copies the script, renames it to `flactoaiff` for easier typing, and places it in `/usr/local/bin`. You will likely need to enter your password.
    ```bash
    sudo cp script/flactoaiff.sh /usr/local/bin/flactoaiff
    ```

2.  **Make it executable**:
    Ensure the copied script has execute permissions.
    ```bash
    sudo chmod +x /usr/local/bin/flactoaiff
    ```

3.  **Run it from anywhere**:
    You can now open a new terminal and run the script from any directory.
    ```bash
    flactoaiff
    # or with the keep option
    flactoaiff -k
    ```

#### Method 2: Add the Script's Directory to your PATH

This method allows you to run the script from its original location. You'll need to add the script's parent directory to your shell's configuration file.

1.  **Find the script's absolute path**:
    Navigate to the `flac_to_aiff` project directory in your terminal and run:
    ```bash
    cd script && echo "The path to add is: $(pwd)"
    ```
    Copy the output path for the next step.

2.  **Edit your shell profile**:
    -   **For macOS (Zsh)**: Open `~/.zshrc` in a text editor (e.g., `nano ~/.zshrc`).
    -   **For most Linux distros (Bash)**: Open `~/.bashrc` or `~/.bash_profile`.

3.  **Add the PATH export command**:
    Add the following line to the end of the file, replacing `"/path/to/your/script/directory"` with the path you copied in step 1.
    ```bash
    export PATH="/path/to/your/script/directory:$PATH"
    ```

4.  **Apply the changes**:
    Open a new terminal window or run `source ~/.zshrc` (for Zsh) or `source ~/.bashrc` (for Bash) to update your current session.


## How It Works

The script recursively scans the specified directory for files with the `.flac` extension. For each file found, it uses `ffmpeg` with the following key parameters:

-   `-i "$FLAC_FILE_NAME"`: Specifies the input file.
-   `-map 0`: Selects all streams from the input (audio, video, attachments).
-   `-c:v copy`: Copies the video stream (album art) without re-encoding.
-   `-c:a pcm_s16be`: Sets the audio codec to 16-bit PCM for lossless AIFF.
-   `-write_id3v2 1`: Ensures ID3v2 metadata tags are written to the new file.