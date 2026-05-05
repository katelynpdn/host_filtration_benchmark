#!/bin/bash
#SBATCH -J deacon 
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  
#SBATCH --exclusive

/usr/bin/time -v deacon filter -d /ddn_scratch/kan028/projects/2025-9-30_biobloom/panhuman-1 /ddn_scratch/lxxu/shotgun/AkiyamaNishijima2024/PRJNA1169537/SRR31312341_1.fastq.gz /ddn_scratch/lxxu/shotgun/AkiyamaNishijima2024/PRJNA1169537/SRR31312341_2.fastq.gz -a 1 -r 0.025 -o deacon_results/hits_SRR31312341

 
