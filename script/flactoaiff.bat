@echo off
setlocal enabledelayedexpansion

:: This script converts all .flac files in the current directory and subdirectories to .aiff format.

echo This script will convert all flac files to aiff files.

:: --- Configuration ---
:: Check for -k or /k flag to keep original files
set "KEEP_ORIGINAL_FILES="
if /i "%1" == "-k" set "KEEP_ORIGINAL_FILES=true"
if /i "%1" == "/k" set "KEEP_ORIGINAL_FILES=true"

:: Inform the user of the operational mode
if defined KEEP_ORIGINAL_FILES (
    echo Keep option activated: Original FLAC files will be preserved.
) else (
    echo Default mode: Original FLAC files will be deleted after conversion.
)
echo ----------------------------------------

:: --- Prerequisite Check ---
:: Check if ffmpeg is installed and in the PATH
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo ERROR: ffmpeg.exe not found in your system's PATH.
    echo Please install ffmpeg from https://ffmpeg.org/ and ensure it is accessible.
    goto :eof
)

:: --- Main Execution ---
:: Use for /r to recursively find all .flac files starting from the current directory (.)
for /r . %%F in (*.flac) do (
    echo Processing "%%F"

    set "FLAC_FILE=%%F"
    set "AIFF_FILENAME=%%~nF.aiff"
    set "SOURCE_DIR=%%~dpF"

    set "OUTPUT_PATH="

    if defined KEEP_ORIGINAL_FILES (
        set "OUTPUT_DIR=!SOURCE_DIR!flac_to_aiff"
        mkdir "!OUTPUT_DIR!" 2>nul
        set "OUTPUT_PATH=!OUTPUT_DIR!\!AIFF_FILENAME!"
    ) else (
        set "OUTPUT_PATH=!SOURCE_DIR!!AIFF_FILENAME!"
    )

    echo Converting "!FLAC_FILE!" to "!OUTPUT_PATH!"
    ffmpeg -loglevel quiet -n -i "!FLAC_FILE!" -map 0 -c:v copy -c:a pcm_s16be -write_id3v2 1 "!OUTPUT_PATH!"

    if not errorlevel 1 (
        echo Conversion successful.
        if not defined KEEP_ORIGINAL_FILES (
            echo Deleting original file: "!FLAC_FILE!"
            del "!FLAC_FILE!"
        )
    ) else (
        echo Conversion failed with error code: !errorlevel!
    )
    
    echo Processing "%%F" done!
    echo ----------------------------------------
)

echo.
echo All conversions finished.

endlocal
goto :eof
