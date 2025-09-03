package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/pterm/pterm"
)

func main() {
	// --- Prerequisite Check ---
	if _, err := exec.LookPath("ffmpeg"); err != nil {
		pterm.Error.Println("ffmpeg not found. Please make sure it is installed and in your PATH.")
		os.Exit(1)
	}

	// --- Configuration ---
	keepOriginal := flag.Bool("k", false, "Keep original FLAC files after conversion.")
	flag.Parse()

	pterm.Info.Println("This script will convert all .flac files to .aiff files")
	if *keepOriginal {
		pterm.Info.Println("Keep option activated: Original FLAC files will be preserved.")
	} else {
		pterm.Info.Println("Default mode: Original FLAC files will be deleted after conversion.")
	}
	pterm.Println("----------------------------------------")

	// --- File Discovery ---
	pterm.Info.Println("Searching for FLAC files...")
	baseDir, err := os.Getwd()
	if err != nil {
		pterm.Error.Printf("Could not get current directory: %v\n", err)
		os.Exit(1)
	}

	var flacFiles []string
	err = filepath.Walk(baseDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(strings.ToLower(info.Name()), ".flac") {
			flacFiles = append(flacFiles, path)
		}
		return nil
	})

	if err != nil {
		pterm.Error.Printf("Error walking directory: %v\n", err)
		os.Exit(1)
	}

	if len(flacFiles) == 0 {
		pterm.Warning.Println("No FLAC files found.")
		return
	}

	pterm.Info.Printf("%d FLAC files found.\n", len(flacFiles))
	pterm.Println("----------------------------------------")

	// --- Processing Loop ---
	multi := pterm.DefaultMultiPrinter
	multi.Start()

	s, _ := pterm.DefaultSpinner.WithWriter(multi.NewWriter()).Start()
	p, _ := pterm.DefaultProgressbar.WithTotal(len(flacFiles)).WithTitle("Converting files").WithWriter(multi.NewWriter()).Start()

	convertedCount := 0
	for _, flacPath := range flacFiles {
		s.UpdateText("Converting " + filepath.Base(flacPath))
		err := processFile(flacPath, *keepOriginal)
		if err != nil {
			pterm.Error.Printf("Failed to process %s: %v\n", filepath.Base(flacPath), err)
		} else {
			convertedCount++
		}
		p.Increment()
	}
	multi.Stop()

	pterm.Println("----------------------------------------")
	pterm.Info.Printf("Conversion process finished. %d/%d files converted successfully.\n", convertedCount, len(flacFiles))
}

func processFile(flacPath string, keepOriginal bool) error {
	ext := filepath.Ext(flacPath)
	aiffPath := flacPath[0:len(flacPath)-len(ext)] + ".aiff"
	aiffBaseName := filepath.Base(aiffPath)

	if keepOriginal {
		outputDir := filepath.Join(filepath.Dir(flacPath), "flac_to_aiff")
		if err := os.MkdirAll(outputDir, os.ModePerm); err != nil {
			return fmt.Errorf("could not create output directory: %w", err)
		}
		aiffPath = filepath.Join(outputDir, aiffBaseName)
	}

	cmd := exec.Command("ffmpeg",
		"-loglevel", "quiet",
		"-n",
		"-i", flacPath,
		"-map", "0",
		"-c:v", "copy",
		"-c:a", "pcm_s16be",
		"-write_id3v2", "1",
		aiffPath,
	)

	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("ffmpeg error: %w\nOutput: %s", err, string(output))
	}

	if !keepOriginal {
		if err := os.Remove(flacPath); err != nil {
			// Log the error but don't fail the whole process just because deletion failed
			pterm.Warning.Printf("Failed to delete original file %s: %v\n", flacPath, err)
		}
	}
	return nil
}
