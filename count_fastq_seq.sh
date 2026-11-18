#!/bin/bash
# Usage: ./count_fastq_sequences.sh /path/to/fastq_dir
DIR="$1"
if [[ -z "$DIR" || ! -d "$DIR" ]]; then
  echo "Usage: $0 /path/to/fastq_dir"
  exit 1
fi
total=0
for file in "$DIR"/*; do
  # Skip if not a regular file
  [[ -f "$file" ]] || continue

  lines=$(wc -l < "$file")
  seqs=$((lines / 4))
  echo "$(basename "$file"): $seqs sequences"

  total=$((total + seqs))
done
echo "Total sequences: $total"
