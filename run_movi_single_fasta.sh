#!/bin/bash
# Usage: ./run_movi_single_fasta.sh <movi_path> <index> <reads_file> <output_dir>

set -e  # Exit on error

# Check arguments
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <movi_path> <index> <reads_file> <output_dir>"
    echo "  movi_path: Path to movi"
    echo "  index: Movi index"
    echo "  reads_file: FASTQ file containing reads to test"
    echo "  output_dir: directory to store results"
    exit 1
fi

MOVI_PATH=$1
INDEX=$2
READ_FILE=$3
OUTPUT_DIR=$4

module load gcc_14.1.0
module load cmake_3.18.2
source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate seqkit-env

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

/usr/bin/time -v $MOVI_PATH query -i $INDEX -r $READ_FILE --filter -v > movi_filtered.fastq

FN=$(grep -c "HUMAN" movi_filtered.fastq)
echo "medium: TN: $TN, FN=$FN"
