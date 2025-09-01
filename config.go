package main

import (
	"encoding/json"
	"os"
	"path/filepath"
)

type Command struct {
	Name   string `json:"name"`
	Action string `json:"action"`
	URL    string `json:"url"`
}

type Config struct {
	Commands []Command `json:"commands"`
}

func NewConfig(path string) (Config, error) {
	var config Config

	bytes, err := os.ReadFile(filepath.Clean(path))
	if err != nil {
		return config, err
	}

	if err := json.Unmarshal(bytes, &config); err != nil {
		return config, err
	}

	return config, nil
}
