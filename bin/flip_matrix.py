#!/usr/bin/env python3
import re, os, sys
import pandas as pd


# USAGE: python3 flip_matrix.py rnaseq_id /path/to/input/file /path/to/output

def main(rnaseq_id, input, output):
    master =  pd.DataFrame()   
    genes = pd.read_csv(input, sep='\t')
    print(genes)
    rawCounts = genes[["gene_id", "expected_count"]]

    rawCounts = rawCounts.rename(columns={'expected_count': rnaseq_id})
    print(rawCounts)

    swapped = rawCounts.swapaxes("index", "columns")
    print(swapped)
    
    print(f"Counts file will be saved to: {output}")
    print(swapped)
    swapped.to_csv(output, sep=',', header=None, float_format = '%.2f')


main(sys.argv[1], sys.argv[2], sys.argv[3])

