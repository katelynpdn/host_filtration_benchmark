#!/bin/sh
#SBATCH -J biobloomcategorizer
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 32gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate biobloom_env

bf=/home/lpatel/projects/2025-04-29_biobloom/ddn/host_filter.bf

#MEDIUM
r1_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R1.fastq
r2_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R2.fastq

#SMALL
r1_small=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R1.fastq
r2_small=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h100000-m100000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R2.fastq

#LARGE
r1_large=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R1.fastq
r2_large=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h10000000-m10000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R2.fastq

S='binomial'
s=13

#/usr/bin/time -v biobloomcategorizer -t 8 -f "$bf" -S $S -s $s -d -e -p "biobloom_results/categorized" $r1_small $r2_small > biobloom_results/filtered_reads_biobloom_small

/usr/bin/time -v biobloomcategorizer -t 8 -f "$bf" -S $S -s $s -d -e -p "biobloom_results/categorized" $r1_med $r2_med > biobloom_results/filtered_reads_biobloom_med

#/usr/bin/time -v biobloomcategorizer -t 8 -f "$bf" -S $S -s $s -d -e -p "biobloom_results/categorized" $r1_large $r2_large > biobloom_results/filtered_reads_biobloom_large

FP=$(grep -c "MICROBE" biobloom_results/filtered_reads_biobloom_med)
TP=$(grep -c "HUMAN" biobloom_results/filtered_reads_biobloom_med)
echo "medium: FP: $FP, TP=$TP"

#FP=$((1000000 - $(grep -c "MICROBE" deacon_results/cleaned_reads_deacon_small)))
#FN=$(grep -c "HUMAN" deacon_results/cleaned_reads_deacon_small)
#echo "small: FP: $FP, FN=$FN"

#FP=$((10000000 - $(grep -c "MICROBE" deacon_results/cleaned_reads_deacon_large)))
#FN=$(grep -c "HUMAN" deacon_results/cleaned_reads_deacon_large)
#echo "large: FP: $FP, FN=$FN"

