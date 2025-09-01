package main

import (
	"flag"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type saveOutput struct {
	savedOutput []byte
}

func (so *saveOutput) Write(p []byte) (n int, err error) {
	so.savedOutput = append(so.savedOutput, p...)
	return os.Stdout.Write(p)
}

func runAction(action string) error {
	var so saveOutput
	parts := strings.Split(action, " ")
	cmd := exec.Command(parts[0], parts[1:]...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = &so
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	fmt.Printf("I got this output: %s\n", so.savedOutput)

	return err
}

func main() {
	configPath := flag.String("config", filepath.Join(os.Getenv("HOME"), ".config/control-http-home/config.json"), "Path to config file")
	flag.Parse()

	config, err := NewConfig(*configPath)
	if err != nil {
		slog.Error("Error reading config", "error", err)
		return
	}

	slog.Info("HTTP server starting on port 42068.")

	for _, com := range config.Commands {
		com := com
		http.HandleFunc(com.URL, func(w http.ResponseWriter, r *http.Request) {
			fmt.Println(com)
			if err := runAction(com.Action); err != nil {
				slog.Error("Error running action.", "error", err)
				http.Error(w, "Failed to run action", http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			w.Write([]byte("Action executed successfully."))
		})
	}

	if err := http.ListenAndServe(":42068", nil); err != nil {
		slog.Error("Error starting HTTP server.", "error", err)
		return
	}
}
