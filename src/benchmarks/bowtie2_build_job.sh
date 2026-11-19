#!/bin/sh
#SBATCH -J bowtie2
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate bowtie-env

# Path to T2T
ref=~/ddn_scratch/projects/2025-9-30_biobloom/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna
# Path to save index to
index=/home/kan028/projects/2025-9-30_biobloom/host_filtration_benchmark/T2T

bowtie2-build $ref $index
