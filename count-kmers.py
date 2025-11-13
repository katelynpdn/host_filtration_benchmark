#!/usr/bin/env python3
"""
Count unique k-mers in FASTA files.
Usage: python kmer_counter.py <k> <fasta_1> [fasta_2] [...] [fasta_n]
"""

import sys
import os
import time
from collections import defaultdict

def count_kmers(k, fasta_files):
    """Count unique k-mers in the provided FASTA files."""
    start_time = time.time()
    kmers = set()
    total_seq_length = 0
    
    for file_num, fn in enumerate(fasta_files):
        if not os.path.exists(fn):
            print(f"Error: File {fn} not found", file=sys.stderr)
            continue
            
        file_size = os.path.getsize(fn) / (1024 * 1024)  # Size in MB
        print(f"Processing file {file_num+1}/{len(fasta_files)}: {fn} ({file_size:.2f} MB)")
        
        sequence = ""
        with open(fn, 'r', buffering=1048576) as f:
            for line in f:
                if line.startswith('>'):
                    if sequence:
                        # Process the completed sequence
                        total_seq_length += len(sequence)
                        new_kmers = {sequence[i:i+k] for i in range(len(sequence)-k+1)}
                        kmers.update(new_kmers)
                        sequence = ""
                else:
                    sequence += line.strip().upper()
            
            # Process the last sequence
            if sequence:
                total_seq_length += len(sequence)
                new_kmers = {sequence[i:i+k] for i in range(len(sequence)-k+1)}
                kmers.update(new_kmers)
    
    elapsed_time = time.time() - start_time
    
    print(f"\nResults:")
    print(f"K-mer size: {k}")
    print(f"Total sequence length: {total_seq_length:,} bp")
    print(f"Theoretical maximum k-mers: {total_seq_length-k+1:,}")
    print(f"Unique k-mers found: {len(kmers):,}")
    print(f"Processing time: {elapsed_time:.2f} seconds")
    
    return len(kmers)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <k> <fasta_1> [fasta_2] [...] [fasta_n]")
        sys.exit(1)
    
    try:
        k = int(sys.argv[1])
    except ValueError:
        print(f"Error: k must be an integer, got {sys.argv[1]}", file=sys.stderr)
        sys.exit(1)
    
    if k <= 0:
        print(f"Error: k must be positive, got {k}", file=sys.stderr)
        sys.exit(1)
    
    fasta_files = sys.argv[2:]
    unique_kmers = count_kmers(k, fasta_files)
    print(unique_kmers)  # Simple output for scripting
