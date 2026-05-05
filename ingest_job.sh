#!/bin/sh
#SBATCH -J ingest
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=8 
#SBATCH --partition=short 
#SBATCH --mem 64gb 
#SBATCH --mail-user=kan028@ucsd.edu 
#SBATCH --mail-type=ALL  

source /home/kan028/projects/2025-9-30_biobloom/host_filtration_benchmark/kl-ingest/.venv/bin/activate
which python
which ingest
echo $PATH

if [ $# -lt 2 ]; then
	echo "Usage: ./ingest_job.sh <output_directory> <accession_numbers>"
fi

OUT=$(realpath -s $1)
for arg in "${@:2}"; do
	echo "Downloading accession $arg..."
	ingest run $arg --format qiita --validator generic_sample -o "${OUT}/$arg/"
done
