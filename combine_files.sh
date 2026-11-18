#!/bin/bash
#Usage: ./combine_files.sh <folder_path> <output_dir>
# Unzip all files, combine all _1 and all _2 files

set -e  # Exit on error

# Check arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <folder_path> <output_dir>"
    echo "  folder_path: Folder path to read files"
    echo "  output_dir: Directory to store results"
    exit 1
fi

FOLDER_PATH=$1
FOLDER_NAME=$( basename "$FOLDER_PATH" )
OUTPUT_DIR=$2 
OUTPUT_DIR="${OUTPUT_DIR%/}" # Remove trailing slash

cd $FOLDER_PATH

zcat *_1.fastq.gz > $OUTPUT_DIR/${FOLDER_NAME}_R1.fastq
zcat *_2.fastq.gz > $OUTPUT_DIR/${FOLDER_NAME}_R2.fastq
