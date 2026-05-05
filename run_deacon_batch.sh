#!/bin/bash
#SBATCH -J deacon_batch
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=short
#SBATCH --mem=64gb
#SBATCH --mail-user=kan028@ucsd.edu
#SBATCH --mail-type=ALL
#SBATCH --exclusive

# Given input directory, run deacon on all paired-end fastq.gz files
if [ "$#" -ne 2 ]; then
	echo "Usage: $0 INPUT_DIR OUT_NAME"
	exit 1
fi

INPUT_DIR="${1%/}"
OUT_NAME="${2%/}"
OUTPUT_DIR="/home/kan028/projects/2025-9-30_biobloom/host_filtration_benchmark/deacon_results/${OUT_NAME}"
DB_PATH="/ddn_scratch/kan028/projects/2025-9-30_biobloom/panhuman-1"
echo "Input dir: ${INPUT_DIR}"
echo "Output dir: ${OUTPUT_DIR}"
echo "Filter path: ${DB_PATH}"
mkdir -p "${OUTPUT_DIR}"

# Loop through R1 files
for R1 in "${INPUT_DIR}"/*_R1.fastq.gz "${INPUT_DIR}"/*_1.fastq.gz; do 
	# Skip if R1 does not exist
	if [ ! -e "$R1" ]; then
    		continue
	fi

	# Check for _R1 and _1.fastq.gz
	if [[ "$R1" == *_R1.fastq.gz ]]; then
        	R2="${R1/_R1.fastq.gz/_R2.fastq.gz}"
        	SAMPLE=$(basename "$R1" _R1.fastq.gz)
    	elif [[ "$R1" == *_1.fastq.gz ]]; then
        	R2="${R1/_1.fastq.gz/_2.fastq.gz}"
        	SAMPLE=$(basename "$R1" _1.fastq.gz)
    	else
        	continue
    	fi
	
	# If R2 doesn't exist, run Deacon on single-read mode
    	if [[ ! -f "$R2" ]]; then
        	echo "missing pair for $R1, running on single-read mode"
		/usr/bin/time -v deacon filter -d "$DB_PATH" "$R1" -a 1 -r 0.02 -o "${OUTPUT_DIR}/hits_${SAMPLE}"
    	fi

    	echo "Processing sample: $SAMPLE"

	/usr/bin/time -v deacon filter -d "$DB_PATH" "$R1" "$R2" -a 1 -r 0.02 -o "${OUTPUT_DIR}/hits_${SAMPLE}"

done

echo "Finished running deacon"
