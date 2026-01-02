# Define the shell
SHELL := /bin/bash

# Directory containing PDF files
PDF_DIR := .
# Directory to place SVG files
SVG_DIR := ./svg

# Scaling factor
SCALE := 1.5

PDF_INPUT := $(wildcard $(PDF_DIR)/*.pdf)
SVG_INPUT := $(wildcard $(SVG_DIR)/*.svg)

SVG_OUTPUT :=  $(patsubst $(PDF_DIR)/%.pdf,$(SVG_DIR)/%.svg,$(PDF_INPUT))

# Default target

svg: $(SVG_OUTPUT) 

all: svg rsvg

# Rule to convert PDF to SVG
$(SVG_DIR)/%.svg: $(PDF_DIR)/%.pdf
	@mkdir -p $(SVG_DIR)
	mutool convert -F svg -o $@ $<

# Clean up generated SVG files
clean:
	rm -f $(SVG_DIR)/*.svg

.PHONY: all clean

