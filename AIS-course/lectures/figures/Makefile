# Same conventions as ../../stochastic-optimization/figures/Makefile
SHELL := /bin/bash

PDF_DIR := .
SVG_DIR := ./svg

PDF_INPUT := $(wildcard $(PDF_DIR)/*.pdf)
SVG_OUTPUT := $(patsubst $(PDF_DIR)/%.pdf,$(SVG_DIR)/%.svg,$(PDF_INPUT))

svg: $(SVG_OUTPUT)

all: svg

$(SVG_DIR)/%.svg: $(PDF_DIR)/%.pdf
	@mkdir -p $(SVG_DIR)
	mutool convert -F svg -o $@ $<

clean:
	rm -f $(SVG_DIR)/*.svg

.PHONY: all svg clean
