#!/bin/sh
#SBATCH -J deacon 
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  
#SBATCH --exclusive

#MEDIUM
r1=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R1.fastq
r2=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R2.fastq

#SMALL
r1_small=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R1.fastq
r2_small=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R2.fastq

#LARGE
r1_large=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R1.fastq
r2_large=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R2.fastq

a=1
r=0.020

#/usr/bin/time -v deacon filter -d /ddn_scratch/kan028/projects/2025-9-30_biobloom/panhuman-1 $r1_small $r2_small -a $a -r $r -o deacon_results/cleaned_reads_deacon_small

time deacon filter -d /ddn_scratch/kan028/projects/2025-9-30_biobloom/panhuman-1 $r1 $r2 -a $a -r $r -o deacon_results/cleaned_reads_deacon_medium

#/usr/bin/time -v deacon filter -d /ddn_scratch/kan028/projects/2025-9-30_biobloom/panhuman-1 $r1_large $r2_large -a $a -r $r -o deacon_results/cleaned_reads_deacon_large

#FP=$((100000 - $(grep -c "MICROBE" deacon_results/cleaned_reads_deacon_small)))
#FN=$(grep -c "HUMAN" deacon_results/cleaned_reads_deacon_small)
#echo "small: FP: $FP, FN=$FN"

FP=$((1000000 - $(grep -c "MICROBE" deacon_results/cleaned_reads_deacon_medium)))
FN=$(grep -c "HUMAN" deacon_results/cleaned_reads_deacon_medium)
echo "medium: FP: $FP, FN=$FN"

#FP=$((10000000 - $(grep -c "MICROBE" deacon_results/cleaned_reads_deacon_large)))
#FN=$(grep -c "HUMAN" deacon_results/cleaned_reads_deacon_large)
#echo "large: FP: $FP, FN=$FN"
