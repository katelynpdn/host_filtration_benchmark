#!/bin/bash
# For each file in a list of files, 
# write a csv file with accession, sample name, and percentage hits

if [ $# -eq 0 ]; then
	echo "Usage: $0 slurm-*.out"
	exit 1
fi

out_csv="hits_per_sample.csv"
echo "accession,sample_name,percentage_hits" > "$out_csv"

for file in "$@"; do
	if [ ! -f "$file" ]; then
		echo "Couldn't find $file, skipping..."
		continue
	fi

	accession=$(grep "Input dir" "$file" | awk -F '/' '{print $NF}')
	mapfile -t sample_names < <(grep "Processing sample" "$file" | cut -d ' ' -f3)
	mapfile -t percentage_hits < <(grep "Retained" "$file" | cut -d ' ' -f2 | awk -F '/' '{print ($2 - $1) / $2}')

	for i in "${!sample_names[@]}"; do
		echo "${accession},${sample_names[$i]},${percentage_hits[$i]}" >> "$out_csv"
	done
done

echo "Saved to $out_csv"
