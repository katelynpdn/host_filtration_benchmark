#!/bin/sh
#SBATCH -J srascrubber 
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

#Medium dataset
#r1=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R1.fastq
#r2=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R2.fastq

#Small dataset
r1=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R1.fastq
r2=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R2.fastq

#Large dataset
#r1=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R1.fastq
#r2=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R2.fastq

source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate human-filtration

seqtk mergepe $r1 $r2 > interleaved.fastq

mkdir -p small/sra-results

/usr/bin/time -v ./sra-human-scrubber/scripts/scrub.sh -i interleaved.fastq -p 8 -o small/sra-results/cleaned.fastq -s -x -r
