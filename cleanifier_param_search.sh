#!/bin/bash
#Usage: ./cleanifier_param_search.sh <index> <reads_R1> <reads_R2> <output_dir>

set -euo pipefail

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <bloom_filter> <reads_file_R1> <reads_file_R2> <output_dir>"
    exit 1
fi

INDEX="$1"
R1_FILE="$2"
R2_FILE="$3"
OUTPUT_DIR="$4"

mkdir -p "$OUTPUT_DIR"/{logs,filters,cleanifier_results}

LOG_FILE="$OUTPUT_DIR/logs/cleanifier_param_search_$(date +%Y%m%d_%H%M%S).log"
RESULTS_CSV="$OUTPUT_DIR/cleanifier_results/parameter_results.csv"

measure_benchmark() {
   {
        /usr/bin/time -v "$@" 1>&3
    } 2>&1 | awk '
        /User time \(seconds\):/ {user=$4}
        /System time \(seconds\):/ {sys=$4}
        /Maximum resident set size \(kbytes\):/ {rss=$6}
        END { printf "user_sys=%.3f\nrss=%d\n", user+sys, rss }
    '
}

FIRST_CHAR=$(head -c1 "$R1_FILE")
if [[ "$FIRST_CHAR" == ">" ]]; then
    NUM_READS=$(grep -c '^>' "$R1_FILE")
elif [[ "$FIRST_CHAR" == "@" ]]; then
    NUM_READS=$(( $(wc -l < "$R1_FILE") / 4 ))
else
    echo "ERROR: Cannot detect FASTA/FASTQ format for $R1_FILE" >&2
    exit 1
fi
echo "Detected $NUM_READS reads in input." | tee -a "$LOG_FILE"

THRESHOLD_VALUES=(0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8)

if [ ! -f "$RESULTS_CSV" ]; then
    echo "threshold,runtime,memory,fp,fn" > "$RESULTS_CSV"
fi

for threshold in "${THRESHOLD_VALUES[@]}"; do
    echo "Running cleanifier with threshold=$threshold" | tee -a "$LOG_FILE"

    RESULTS_FILE="$OUTPUT_DIR/cleanifier_${threshold}"

    BENCHMARK=$(
    { /usr/bin/time -v cleanifier filter --index $INDEX --fastq $R1_FILE --pairs $R2_FILE --out $RESULTS_FILE --threshold "$threshold"
    } 2>&1 | awk '
        /User time \(seconds\):/ {user=$4}
        /System time \(seconds\):/ {sys=$4}
        /Maximum resident set size \(kbytes\):/ {rss=$6}
        END {printf "user_sys=%.3f\nrss=%d\n", user+sys, rss}
    '
    )

    eval "$BENCHMARK"
    TIME=$user_sys
    MEMORY=$rss

    echo "TIME = $TIME sec"  | tee -a "$LOG_FILE"
    echo "MEMORY = $MEMORY kB" | tee -a "$LOG_FILE"

    RESULTS_1=${RESULTS_FILE}_1_keep.fastq
    RESULTS_2=${RESULTS_FILE}_2_keep.fastq

    TN=$(( $(grep -c "MICROBE" "$RESULTS_1") + $(grep -c "MICROBE" "$RESULTS_2") ))
    FP=$(( 1000000 - $TN ))
    FN=$(( $(grep -c "HUMAN" "$RESULTS_1") + $(grep -c "HUMAN" "$RESULTS_2") ))
    TP=$(( 1000000 - $FN ))

    echo "$threshold,$TIME,$MEMORY,$FP,$FN" >> "$RESULTS_CSV"

    echo "TP=$TP FP=$FP TN=$TN FN=$FN" | tee -a "$LOG_FILE"
    echo "-------------------------------------------------" | tee -a "$LOG_FILE"
done

echo "Parameter search complete. Results saved to $RESULTS_CSV" | tee -a "$LOG_FILE"

