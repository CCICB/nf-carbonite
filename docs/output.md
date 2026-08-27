# nf-carbonite: Output

All results are written to `--outdir`, organized per sample under the sample's
`rnaseq_id`. Optional tools only produce output when their corresponding parameter
was supplied (see [usage.md](usage.md)).

```
<outdir>/
├── <rnaseq_id>/
│   ├── <rnaseq_id>.sorted.rmdup.<ref>.bam(.bai)      Picard-processed alignment (sorted, duplicates removed)
│   ├── <rnaseq_id>_exp.<ref>.genes.results           RSEM gene-level expression
│   ├── <rnaseq_id>_exp.<ref>.isoforms.results        RSEM isoform-level expression
│   ├── <rnaseq_id>_exp.<ref>.named.genes.results     RSEM gene expression with HGNC gene names
│   ├── <rnaseq_id>_TE.<ref>.cntTable                 TEcount transposable-element counts (optional)
│   ├── <rnaseq_id>_results.tsv                       MINTIE novel-variant results (optional, hs38 only)
│   ├── star/                                         STAR alignments (genome + transcriptome BAM)
│   ├── starfusion/                                   STAR-Fusion predictions (full, abridged, preliminary candidates)
│   ├── arriba/                                       Arriba fusions (kept + discarded TSV, fusion plot PDF)
│   ├── gatk/                                         SplitNCigarReads BAM, HaplotypeCaller VCF (+idx),
│   │                                                 ANNOVAR-annotated multianno VCF (optional)
│   ├── freebayes/                                    FreeBayes variant calls (optional, hs38 only)
│   ├── rnaindel/                                     RNAIndel calls, bgzipped + tabix-indexed (optional)
│   ├── isofox/                                       Isofox transcript counts / splice junctions / fusions (optional, hs38 only)
│   ├── mixcr/                                        MiXCR CDR3 repertoire results (optional)
│   ├── allsorts/                                     ALLSorts B-ALL subtype predictions, probabilities, plots
│   └── tallsorts/                                    TALLSorts T-ALL subtype predictions, probabilities, plots
└── pipeline_info/
    ├── software_versions.yml                         Version of each tool actually executed in this run
    ├── execution_report_<timestamp>.html             Nextflow run report
    ├── execution_timeline_<timestamp>.html           Task timeline
    ├── execution_trace_<timestamp>.txt               Per-task trace (resources, exit codes)
    └── pipeline_dag_<timestamp>.html                 Workflow graph
```

`<ref>` is the value of `--ref_genome_version` (`hs38` or `hg19`).

> [!NOTE]
> When `--te_gtf_file` is supplied, two STAR alignments run (one parameterized for
> RSEM, one for TEcount) and both publish to `star/` using the same file names —
> the copy in `star/` is whichever finished last. This is long-standing behaviour;
> the per-tool results downstream of each alignment are unaffected.
