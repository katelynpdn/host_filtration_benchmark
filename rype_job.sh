#!/bin/sh
#SBATCH -J rypebenchmark
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

index=/ddn_scratch/dtmcdonald/2026.02.04-rype/index/Human_unified_w50/Human.ryxdi

#MEDIUM
r1_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R1.fastq
r2_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R2.fastq

#SMALL
r1_small=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R1.fastq
r2_small=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R2.fastq

#LARGE
r1_large=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R1.fastq
r2_large=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R2.fastq

/usr/bin/time -v rype classify run -i $index -1 $r1_med -2 $r2_med -t 0.005

FP=$(grep -c "_MICROBE" slurm-$SLURM_JOB_ID.out)
TP=$(( $(grep -c "_HUMAN" slurm-$SLURM_JOB_ID.out) - 1 ))
echo "medium: FP: $FP, TP=$TP"
