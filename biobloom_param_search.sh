#!/bin/bash
# Usage: ./biobloom_param_search.sh <bloom_filter> <reads_R1> <reads_R2> <output_dir>

set -euo pipefail

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <bloom_filter> <reads_file_R1> <reads_file_R2> <output_dir>"
    exit 1
fi

BLOOM_FILTER="$1"
R1_FILE="$2"
R2_FILE="$3"
OUTPUT_DIR="$4"

mkdir -p "$OUTPUT_DIR"/{logs,filters,biobloom_results}

LOG_FILE="$OUTPUT_DIR/logs/biobloom_param_search_$(date +%Y%m%d_%H%M%S).log"
RESULTS_CSV="$OUTPUT_DIR/biobloom_results/parameter_results.csv"

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

S_VALUES=("binomial")
HARMONIC_SCORE_VALUES=(0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9)
BINOMIAL_SCORE_VALUES=(10 12 13 15 17 19 20 40 60 80 100 120 130 140)

if [ ! -f "$RESULTS_CSV" ]; then
    echo "S,score,runtime,memory,tp,fp,tn,fn" > "$RESULTS_CSV"
fi

for S in "${S_VALUES[@]}"; do
    echo "Testing scoring scheme: $S" | tee -a "$LOG_FILE"

    if [[ "$S" == "harmonic" ]]; then
        SCORE_LIST=("${HARMONIC_SCORE_VALUES[@]}")
    else
        SCORE_LIST=("${BINOMIAL_SCORE_VALUES[@]}")
    fi

    for score in "${SCORE_LIST[@]}"; do
        echo "Running BioBloomCategorizer with S=$S score=$score" | tee -a "$LOG_FILE"

        RESULTS_FILE="$OUTPUT_DIR/biobloom_results/results_${S}_${score}.txt"

        BENCHMARK=$(
        { /usr/bin/time -v biobloomcategorizer -t 8 \
            -f "$BLOOM_FILTER" -s "$score" -S "$S" -d -e -i \
            -p "$OUTPUT_DIR/biobloom_results" \
            "$R1_FILE" "$R2_FILE" \
            > "$RESULTS_FILE"; 
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

        TP=$(grep -c "HUMAN" "$RESULTS_FILE" || true)
        FP=$(grep -c "MICROBE" "$RESULTS_FILE" || true)
        FN=$(( NUM_READS - TP ))
        TN=$(( NUM_READS - FP ))

        echo "$S,$score,$TIME,$MEMORY,$TP,$FP,$TN,$FN" >> "$RESULTS_CSV"

        echo "TP=$TP FP=$FP TN=$TN FN=$FN" | tee -a "$LOG_FILE"
        echo "-------------------------------------------------" | tee -a "$LOG_FILE"
    done
done

echo "Parameter search complete. Results saved to $RESULTS_CSV" | tee -a "$LOG_FILE"

