#!/bin/bash
#SBATCH -J count_seq
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate human-filtration

if [ $# -ne 1 ]; then
	echo "Usage: ./count_seq.sh <input_directory>"
	exit 1
fi

IN=$(realpath -s $1)
first_file=$(ls -1 $IN | head -n 1)

if [[ "$first_file" == *.fastq.gz || "$first_file" == *.txt || "$first_file" == *.tsv ]]; then
	IN_FILES="${IN}/*.fastq.gz"
else
	IN_FILES="${IN}/*"
fi
echo "Counting all sequences in $IN_FILES"

seqkit stats -T $IN_FILES | awk 'NR>1 {sum += $4} END {print "Total:", sum}'
