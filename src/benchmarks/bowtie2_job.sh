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

# Path to bowtie indices that you built
index=~/ddn_scratch/projects/2025-9-30_biobloom/bowtie_index/T2T

#MEDIUM
r1_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R1.fastq
r2_med=/ddn_scratch/cguccion/23_11_07_HostDepletionBenchmarkOverflow/mixed_simulation_tmp/final_combo/LITTLE_50.00p-HUMAN_50.00p-MICROBE/raw/fastq_paired/h1000000-m1000000/50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h1000000-m1000000_R2.fastq

#SMALL
r1_small=~/ddn_scratch/projects/2025-9-30_biobloom/small_100000/v2_50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R1.fastq
r2_small=~/ddn_scratch/projects/2025-9-30_biobloom/small_100000/v2_50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h100000-m100000_R2.fastq

#LARGE
r1_large=~/ddn_scratch/projects/2025-9-30_biobloom/large_10000000/v2_50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R1.fastq
r2_large=~/ddn_scratch/projects/2025-9-30_biobloom/large_10000000/v2_50.00p-HG00733.maternal_50.00p-FDA-ARGO-51_sim_SUB-h10000000-m10000000_R2.fastq

out_dir="./large/bowtie_results"
mkdir -p $out_dir

echo "Output directory: ${out_dir}"

/usr/bin/time -v bowtie2 -x $index -1 $r1_large -2 $r2_large --un-conc $out_dir
seqtk mergepe "$out_dir/un-conc-mate.1" "$out_dir/un-conc-mate.2" > "$out_dir/un-conc-mate-interleaved"

TN=$(grep -c "MICROBE" "$out_dir/un-conc-mate-interleaved")
FN=$(grep -c "HUMAN" "$out_dir/un-conc-mate-interleaved")
echo "TN: $TN, FN=$FN"
