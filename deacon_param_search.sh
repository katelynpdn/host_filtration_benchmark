#!/bin/bash
# Usage: ./deacon_param_search.sh <host_fasta_files> <reads_file_R1> <reads_file_R2> <output_dir>

set -e  # Exit on error

# Check arguments
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <host_fasta_files> <reads_file_R1> <reads_file_R2> <output_dir>"
    echo "  deacon_index: Deacon index file"
    echo "  reads_file_R1: FASTQ/FASTA file containing reads to test"
    echo "  reads_file_R2: FASTQ/FASTA file containing reads to test"
    echo "  output_dir: directory to store results"
    exit 1
fi

deacon_index=$1
R1_FILE=$2
R2_FILE=$3
OUTPUT_DIR=$4

mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/logs"
mkdir -p "$OUTPUT_DIR/filters"
mkdir -p "$OUTPUT_DIR/deacon_results"

# Log file
LOG_FILE="$OUTPUT_DIR/logs/biobloom_param_search_$(date +%Y%m%d_%H%M%S).log"

# Function to measure memory, time usage
measure_benchmark() {
    local output
    output=$(/usr/bin/time -v "$@" 2>&1 | awk '
        /User time \(seconds\):/ {user=$4}
        /System time \(seconds\):/ {sys=$4}
        /Maximum resident set size \(kbytes\):/ {rss=$6}
        END { printf "user_sys=%.3f rss=%d", user+sys, rss }')
    echo "$output"
}

# Count reads
FIRST_CHAR=$(head -c1 "$R1_FILE")
if [[ "$FIRST_CHAR" == ">" ]]; then
    # FASTA format
    NUM_READS=$(grep -c '^>' "$R1_FILE")
elif [[ "$FIRST_CHAR" == "@" ]]; then
    # FASTQ format
    NUM_READS=$(( $(wc -l < "$R1_FILE") / 4 ))
else
    echo "Error: File format not detected (not FASTA or FASTQ)." >&2
    exit 1
fi

# Parameter combinations to test
A_VALUES=(1 2)
R_VALUES=(0.045 0.04 0.035 0.03 0.001)

# Results file header
RESULTS_CSV="$OUTPUT_DIR/deacon_results/parameter_results.csv"
if [ ! -f "$RESULTS_CSV" ]; then
    echo "a,r,runtime,memory,tp,fp,tn,fn" > "$RESULTS_CSV"
fi

# Run parameter search
for A in "${A_VALUES[@]}"; do
    for R in "${R_VALUES[@]}"; do 
        RESULTS_FILE="$OUTPUT_DIR/deacon_results/cleaned_reads_deacon_A${A}_R${R}"

        # Measure time and memory
        eval "$(measure_benchmark deacon filter -d $deacon_index $R1_FILE $R2_FILE -a $A -r $R -o $RESULTS_FILE)"
        TIME=$user_sys
        MEMORY=$rss

        echo "TIME = $TIME seconds"| tee -a $LOG_FILE
        echo "MEMORY = $MEMORY kB" | tee -a $LOG_FILE
        
        # Parse results to get TP/FP/TN/FN
        FN=$(grep -c "HUMAN" "$RESULTS_FILE" 2>/dev/null || echo 0)
        FP=$(( NUM_READS - $(grep -c "MICROBE" "$RESULTS_FILE" 2>/dev/null || echo 0) ))
        TP=$(( NUM_READS - FN ))
        TN=$(( NUM_READS - FP ))
        
        echo "$A,$R,$TIME,$MEMORY,$TP,$FP,$TN,$FN" >> "$RESULTS_CSV"
        
        echo "Results for A=$A and R=$R: TP=$TP, FP=$FP, TN=$TN, FN=$FN" | tee -a $LOG_FILE
    done
done

echo "Parameter search complete. Results saved to $RESULTS_CSV" | tee -a $LOG_FILE
