#!/bin/bash

# pdf to markdown converter script
# converts pdf files to markdown format using pdftotext and saves with .md extension

# check if script is run with an argument
if [ $# -eq 0 ]; then
    echo "usage: $0 <pdf_file_path>"
    echo "example: $0 /path/to/document.pdf"
    exit 1
fi

# get the pdf file path
pdf_path="$1"

# check if file exists
if [ ! -f "$pdf_path" ]; then
    echo "error: file not found: $pdf_path"
    exit 1
fi

# check if file is a pdf
if [[ ! "$pdf_path" =~ \.pdf$ ]]; then
    echo "error: file must have .pdf extension"
    exit 1
fi

# check if pdftotext is installed
if ! command -v pdftotext &> /dev/null; then
    echo "error: pdftotext is not installed"
    echo "install with: sudo dnf install poppler-utils"
    exit 1
fi

# get directory and filename
pdf_dir=$(dirname "$pdf_path")
pdf_filename=$(basename "$pdf_path")
pdf_basename="${pdf_filename%.pdf}"

# create output path
output_path="${pdf_dir}/${pdf_basename}.md"

# convert pdf to text with layout preservation
echo "converting $pdf_filename to markdown..."
pdftotext -layout "$pdf_path" - > "$output_path"

# check if conversion was successful
if [ $? -eq 0 ] && [ -f "$output_path" ]; then
    echo "success: converted to $output_path"
    echo "file size: $(wc -l < "$output_path") lines"
else
    echo "error: conversion failed"
    exit 1
fi
