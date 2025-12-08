#!/bin/sh
#SBATCH -J cleanifier_param
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 32gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

source /home/kan028/miniforge3/etc/profile.d/conda.sh
conda activate cleanifier

index=~/ddn_scratch/projects/2025-9-30_biobloom/t2t_pangenome_hla_variants_cdna_cleanifier_index_k29_w33.filter

#MEDIUM
r1_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R1.fastq
r2_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R2.fastq

mkdir -p cleanifier_results

./cleanifier_param_search.sh $index $r1_med $r2_med cleanifier_results
