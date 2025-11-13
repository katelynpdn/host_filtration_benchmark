#!/bin/bash
# Usage: ./biobloom_param_search.sh <host_fasta_files> <reads_file_R1> <reads_file_R2> <output_dir>

set -e  # Exit on error

# Check arguments
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <host_fasta_files> <reads_file_R1> <reads_file_R2> <output_dir>"
    echo "  host_fasta_files: comma-separated list of host FASTA files"
    echo "  reads_file_R1: FASTQ/FASTA file containing reads to test"
    echo "  reads_file_R2: FASTQ/FASTA file containing reads to test"
    echo "  output_dir: directory to store results"
    exit 1
fi

HOST_FILES=$(echo $1 | tr ',' ' ')
R1_FILE=$2
R2_FILE=$3
OUTPUT_DIR=$4

mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/logs
mkdir -p $OUTPUT_DIR/filters
mkdir -p $OUTPUT_DIR/results

# Log file
LOG_FILE="$OUTPUT_DIR/logs/param_search_$(date +%Y%m%d_%H%M%S).log"

# Function to measure memory, time usage
measure_benchmark() {
    /usr/bin/time -v "$@" 2>&1
}

# Calculate unique k-mers in host files
echo "Calculating unique k-mers in host files..." | tee -a $LOG_FILE
for K in 21 25 31; do
    echo "Counting k-mers with k=$K..." | tee -a $LOG_FILE
    NUM_KMERS=$(python count-kmers.py $K $HOST_FILES)
    echo "Found $NUM_KMERS unique ${K}-mers" | tee -a $LOG_FILE
    
    # Save to parameter list
    echo "$K,$NUM_KMERS" >> $OUTPUT_DIR/kmer_counts.csv
done

# Extract default k-mer count for k=25 (BioBloom default)
DEFAULT_K=25
DEFAULT_NUM_KMERS=$(grep "^$DEFAULT_K," $OUTPUT_DIR/kmer_counts.csv | cut -d',' -f2)

# Parameter combinations to test
K_VALUES=(21 25 31)
# NUM_ELE_FACTORS=(0.8 1.0 1.2)  # Factors to multiply the k-mer count by
# FPR_VALUES=(0.001 0.0075 0.01)  # False positive rates

# Results file header
# echo "k,num_ele,fpr,runtime,memory,tp,fp,tn,fn" > $OUTPUT_DIR/results/parameter_results.csv

# Subsamples of reads for progressive testing
# SUBSAMPLE_SIZES=(1000 10000 100000)
# if [ -f $READS_FILE ]; then
#     for SIZE in "${SUBSAMPLE_SIZES[@]}"; do
#         echo "Creating subsample of $SIZE reads..." | tee -a $LOG_FILE
#         if [[ $READS_FILE == *.fastq ]] || [[ $READS_FILE == *.fq ]]; then
#             head -n $((SIZE*4)) $READS_FILE > $OUTPUT_DIR/reads_${SIZE}.fastq
#         else
#             # Assume FASTA format - more complex to subsample, this is simplified
#             awk -v max=$SIZE 'BEGIN{n=0} /^>/{n++} n<=max' $READS_FILE > $OUTPUT_DIR/reads_${SIZE}.fasta
#         fi
#     done
# fi

# Run parameter search
for K in "${K_VALUES[@]}"; do
    # Get k-mer count for this k
    NUM_KMERS=$(grep "^$K," $OUTPUT_DIR/kmer_counts.csv | cut -d',' -f2)
    FILTER_PREFIX="$OUTPUT_DIR/filter"
    
    echo "Creating filter" | tee -a $LOG_FILE
    
    # Measure creation time and memory
    # START_TIME=$(date +%s)
    MEM_USAGE=$(measure_benchmark biobloommaker -t 8 -k $K -n $NUM_ELE -f $FPR -p $FILTER_PREFIX $HOST_FILES)
    # END_TIME=$(date +%s)
    # RUNTIME=$((END_TIME - START_TIME))
    
    echo "Filter created in ${MEM_USAGE}" | tee -a $LOG_FILE
    
    # Run biobloomcategorizer
    RESULTS_FILE="$OUTPUT_DIR/results/results_k${K}_n${NUM_ELE}_fpr${FPR}_reads${SIZE}.tsv"
    /usr/bin/time -v biobloomcategorizer -t 8 -f "$FILTER_PREFIX.bf" -s 1 -e -i -p "$OUTPUT_DIR/results/categorized" $R1_FILE $R2_FILE > $RESULTS_FILE
    
    # Parse results to get TP/FP/TN/FN
    # This is a simplified version - would need customization for your specific test data setup
    TP=$(grep -c "positive" $RESULTS_FILE || echo 0)
    FP=$(grep -c "false_positive" $RESULTS_FILE || echo 0)
    TN=$(grep -c "negative" $RESULTS_FILE || echo 0)
    FN=$(grep -c "false_negative" $RESULTS_FILE || echo 0)
    
    # echo "$K,$NUM_ELE,$FPR,$RUNTIME,$MEM_USAGE,$TP,$FP,$TN,$FN,$SIZE" >> $OUTPUT_DIR/results/parameter_results.csv
    
    echo "Results for K=$K: TP=$TP, FP=$FP, TN=$TN, FN=$FN" | tee -a $LOG_FILE
done

echo "Parameter search complete. Results saved to $OUTPUT_DIR/results/parameter_results.csv" | tee -a $LOG_FILE

# chmod +x $OUTPUT_DIR/plot_results.py
# echo "Run 'python $OUTPUT_DIR/plot_results.py $OUTPUT_DIR/results/parameter_results.csv' to generate plots" | tee -a $LOG_FILE
