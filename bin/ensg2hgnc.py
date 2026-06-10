#!/usr/bin/env python3
import glob
import pandas as pd
import os, sys

# Usage
# python3 ensg2hgnc.py /path/to/gencode_v41_ensg_hgnc.csv /path/to/genes/results rnaseq_id

def ensg2hgnc(csv_path, genes, rnaseq_id):
    print(csv_path, genes, rnaseq_id)
    filename = os.path.basename(genes).replace("genes", "named.genes")
    anno = pd.read_csv(csv_path, sep=',', header = 0 )
    anno = anno[['gene_id', 'gene_name']]

    for file in glob.glob(genes, recursive=True):
        f =  pd.read_csv(file, sep='\t', float_precision='high', header = 0)

        if 'gene_name' not in f.columns:
            f['gene_name'] = f['gene_id']
            cols = list(f.columns)
            cols = [cols[-1]] + cols[:-1]
            f = f[cols]
            f.to_csv("./" + filename, sep='\t', index=False,float_format = '%.2f') # Save new dataframe
            return
        merge = f.merge(anno, how = "left", on = ["gene_id"]) # Merge dataframes
        cols = list(merge.columns)
        cols = [cols[-1]] + cols[:-1]
        merge = merge[cols]
        merge.to_csv("./" + filename, sep='\t', index=False,float_format = '%.2f') # Save new dataframe

ensg2hgnc(sys.argv[1], sys.argv[2], sys.argv[3])