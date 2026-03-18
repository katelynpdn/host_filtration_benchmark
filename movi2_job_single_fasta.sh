#!/bin/sh
#SBATCH -J movi2
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 128gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

module load gcc_14.1.0
module load cmake_3.18.2
index=/home/kan028/ddn_scratch/projects/2025-9-30_biobloom/movi_regular_thresholds

readfile=/ddn_scratch/lpatel/projects/2025-04-02_caitriona-host-filter/rerun/marine-2/fastp/Marine_PM_Day_1_AM_Zengler_S000_L001_R1_001.trimmed.FASTP.fastq

./run_movi_single_fasta.sh /home/kan028/projects/2025-9-30_biobloom/Movi/build/movi $index $readfile movi_results
