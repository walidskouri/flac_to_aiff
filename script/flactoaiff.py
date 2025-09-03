#!/usr/bin/env python3
import os
import sys
import subprocess

# --- Import rich or provide a fallback ---
try:
    from rich.progress import (
        Progress,
        BarColumn,
        TextColumn,
        TimeElapsedColumn,
        MofNCompleteColumn,
    )
    from rich.console import Console
    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False
    # Define a dummy Console for consistent printing, and to have the .print method
    class Console:
        def print(self, *args, **kwargs):
            print(*args)

def check_ffmpeg():
    """Checks if ffmpeg is installed and in the system's PATH."""
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True, text=True)
        return True
    except (FileNotFoundError, subprocess.CalledProcessError):
        return False

def process_file(flac_file_name, keep_original_files, console):
    """Converts a single FLAC file to AIFF."""
    aiff_file_name = os.path.splitext(flac_file_name)[0] + ".aiff"

    if keep_original_files:
        output_dir = os.path.join(os.path.dirname(flac_file_name), "flac_to_aiff")
        os.makedirs(output_dir, exist_ok=True)
        aiff_file_name = os.path.join(output_dir, os.path.basename(aiff_file_name))

    command = [
        "ffmpeg", "-loglevel", "quiet", "-n",
        "-i", flac_file_name,
        "-map", "0", "-c:v", "copy", "-c:a", "pcm_s16be",
        "-write_id3v2", "1", aiff_file_name
    ]

    try:
        subprocess.run(command, check=True, capture_output=True, text=True)
        console.print(f"Successfully converted {os.path.basename(flac_file_name)} to {os.path.basename(aiff_file_name)}")
        
        if not keep_original_files:
            os.remove(flac_file_name)
            console.print(f"Deleted original file: {os.path.basename(flac_file_name)}")
        return True
    except subprocess.CalledProcessError as e:
        console.print(f"[red]Error converting {os.path.basename(flac_file_name)}.[/red]")
        console.print(f"ffmpeg stderr: {e.stderr.strip()}")
    except Exception as e:
        console.print(f"[red]An unexpected error occurred with {os.path.basename(flac_file_name)}: {e}[/red]")
    return False

def main():
    """
    Main function to find and convert files.
    """
    console = Console()
    console.print("This script will convert all .flac files to .aiff files")

    # --- Configuration ---
    keep_original_files = "-k" in sys.argv
    if keep_original_files:
        console.print("Keep option activated: Original FLAC files will be preserved.")
    else:
        console.print("Default mode: Original FLAC files will be deleted after conversion.")
    console.print("----------------------------------------")

    # --- File Discovery ---
    basedir = os.getcwd()
    console.print("Searching for FLAC files...")
    flac_files = [os.path.join(r, f) for r, _, fs in os.walk(basedir) for f in fs if f.lower().endswith(".flac")]

    if not flac_files:
        console.print("No FLAC files found.")
        return

    total_files = len(flac_files)
    console.print(f"{total_files} FLAC files found.")
    console.print("----------------------------------------")

    # --- Processing Loop ---
    converted_count = 0
    if RICH_AVAILABLE:
        progress_columns = [
            TextColumn("[bold blue]{task.description}", justify="right"),
            BarColumn(bar_width=None),
            "[progress.percentage]{task.percentage:>3.1f}%", "•",
            MofNCompleteColumn(), "•",
            TimeElapsedColumn(),
        ]
        with Progress(*progress_columns, console=console) as progress:
            task = progress.add_task("Converting...", total=total_files)
            for flac_file in flac_files:
                if process_file(flac_file, keep_original_files, progress.console):
                    converted_count += 1
                progress.update(task, advance=1)
    else:
        console.print("For a progress bar, install the 'rich' library: pip install rich")
        for i, flac_file in enumerate(flac_files):
            console.print(f"Processing file {i+1}/{total_files}: {os.path.basename(flac_file)}")
            if process_file(flac_file, keep_original_files, console):
                converted_count += 1

    console.print("----------------------------------------")
    console.print(f"Conversion process finished. {converted_count}/{total_files} files converted successfully.")

if __name__ == "__main__":
    if not check_ffmpeg():
        Console().print("[red]Error: ffmpeg is not installed or not in your PATH. Please install ffmpeg to use this script.[/red]")
        sys.exit(1)
    main()