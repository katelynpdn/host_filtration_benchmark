#!/bin/bash
# Usage: ./run_movi.sh <movi_path> <index> <reads_file_R1> <reads_file_R2> <output_dir>

set -e  # Exit on error

# Check arguments
if [ "$#" -lt 5 ]; then
    echo "Usage: $0 <movi_path> <index> <reads_file_R1> <reads_file_R2> <output_dir>"
    echo "  movi_path: Path to movi"
    echo "  index: Movi index"
    echo "  reads_file_R1: FASTQ/FASTA file containing reads to test"
    echo "  reads_file_R2: FASTQ/FASTA file containing reads to test"
    echo "  output_dir: directory to store results"
    exit 1
fi

MOVI_PATH=$1
INDEX=$2
R1_FILE=$3
R2_FILE=$4
OUTPUT_DIR=$5

#module load gcc_14.1.0
#module load cmake_3.18.2
source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate seqkit-env

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

cat $R1_FILE $R2_FILE > combined.fastq

/usr/bin/time -v $MOVI_PATH query -i $INDEX -r combined.fastq --filter -v > movi_filtered.fastq

# Split resulting file at first /2 read
csplit movi_filtered.fastq '/\/2$/' -f split

# ---Compute intersection of FASTQ files---
# Save shared sequence headers that exist in both r1 and r2 files
seqkit seq -n split00 | sed 's:/[12]$::' | sort > r1.ids
seqkit seq -n split01 | sed 's:/[12]$::' | sort > r2.ids
comm -12 r1.ids r2.ids > paired.ids

# Create paired.ids with both /1 and /2 at the end, for later hash matching using seqkit grep
sed 's:$:/1:' paired.ids > paired_r1.ids
sed 's:$:/2:' paired.ids > paired_r2.ids

# Extract sequences with the "shared" sequence headers
# Note: can also use seqkit common, but documentation says seqkit grep is faster for 2 files
seqkit grep -n -f paired_r1.ids split00 -o r1_paired.fastq
seqkit grep -n -f paired_r2.ids split01 -o r2_paired.fastq
seqtk mergepe r1_paired.fastq r2_paired.fastq > interleaved.fastq

TN=$(grep -c "MICROBE" interleaved.fastq)
FN=$(grep -c "HUMAN" interleaved.fastq)
echo "medium: TN: $TN, FN=$FN"
