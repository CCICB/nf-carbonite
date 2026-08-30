# nf-carbonite: Citations

## Pipeline framework

- [Nextflow](https://pubmed.ncbi.nlm.nih.gov/28398311/)
  > Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. Nat Biotechnol. 2017 Apr 11;35(4):316-319. doi: 10.1038/nbt.3820.

- [nf-core](https://pubmed.ncbi.nlm.nih.gov/32055031/) (nf-carbonite is not an nf-core pipeline, but borrows its conventions and was originally derived from the nf-core/rnaseq template)
  > Ewels PA, Peltzer A, Fillinger S, Patel H, Alneberg J, Wilm A, Garcia MU, Di Tommaso P, Nahnsen S. The nf-core framework for community-curated bioinformatics pipelines. Nat Biotechnol. 2020 Mar;38(3):276-278. doi: 10.1038/s41587-020-0439-x.

## Alignment and quantification

- [STAR](https://pubmed.ncbi.nlm.nih.gov/23104886/)
  > Dobin A, Davis CA, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P, Chaisson M, Gingeras TR. STAR: ultrafast universal RNA-seq aligner. Bioinformatics. 2013 Jan 1;29(1):15-21. doi: 10.1093/bioinformatics/bts635.

- [RSEM](https://pubmed.ncbi.nlm.nih.gov/21816040/)
  > Li B, Dewey CN. RSEM: accurate transcript quantification from RNA-Seq data with or without a reference genome. BMC Bioinformatics. 2011 Aug 4;12:323. doi: 10.1186/1471-2105-12-323.

- [Picard](https://broadinstitute.github.io/picard/)
  > Broad Institute. Picard toolkit. https://broadinstitute.github.io/picard/

## Fusion detection

- [STAR-Fusion](https://pubmed.ncbi.nlm.nih.gov/31639029/)
  > Haas BJ, Dobin A, Li B, Stransky N, Pochet N, Regev A. Accuracy assessment of fusion transcript detection via read-mapping and de novo fusion transcript assembly-based methods. Genome Biol. 2019 Oct 21;20(1):213. doi: 10.1186/s13059-019-1842-9.

- [Arriba](https://pubmed.ncbi.nlm.nih.gov/33441414/)
  > Uhrig S, Ellermann J, Walther T, Burkhardt P, Fröhlich M, Hutter B, Toprak UH, Neumann O, Stenzinger A, Scholl C, Fröhling S, Brors B. Accurate and efficient detection of gene fusions from RNA sequencing data. Genome Res. 2021 Mar;31(3):448-460. doi: 10.1101/gr.257246.119.

## Variant calling and annotation

- [GATK](https://pubmed.ncbi.nlm.nih.gov/20644199/)
  > McKenna A, Hanna M, Banks E, Sivachenko A, Cibulskis K, Kernytsky A, Garimella K, Altshuler D, Gabriel S, Daly M, DePristo MA. The Genome Analysis Toolkit: a MapReduce framework for analyzing next-generation DNA sequencing data. Genome Res. 2010 Sep;20(9):1297-303. doi: 10.1101/gr.107524.110.

- [FreeBayes](https://arxiv.org/abs/1207.3907)
  > Garrison E, Marth G. Haplotype-based variant detection from short-read sequencing. arXiv preprint arXiv:1207.3907. 2012.

- [RNAIndel](https://pubmed.ncbi.nlm.nih.gov/31593214/)
  > Hagiwara K, Ding L, Edmonson MN, Rice SV, Newman S, Easton J, Dai J, Meshinchi S, Ries RE, Rusch M, Zhang J. RNAIndel: discovering somatic coding indels from tumor RNA-Seq data. Bioinformatics. 2020 Mar 1;36(5):1382-1390. doi: 10.1093/bioinformatics/btz753. Erratum in: Bioinformatics. 2020 Aug 15;36(14):4231. doi: 10.1093/bioinformatics/btaa247. PMID: 31593214; PMCID: PMC7523641.

- [ANNOVAR](https://pubmed.ncbi.nlm.nih.gov/20601685/)
  > Wang K, Li M, Hakonarson H. ANNOVAR: functional annotation of genetic variants from high-throughput sequencing data. Nucleic Acids Res. 2010 Sep;38(16):e164. doi: 10.1093/nar/gkq603.

## Specialized analyses

- [ALLSorts](https://pubmed.ncbi.nlm.nih.gov/35482550/)
  > Schmidt B, Brown LM, Ryland GL, Lonsdale A, Kosasih HJ, Ludlow LE, Majewski IJ, Blombery P, Ekert PG, Davidson NM, Oshlack A. ALLSorts: an RNA-Seq subtype classifier for B-cell acute lymphoblastic leukemia. Blood Adv. 2022 Jul 26;6(14):4093-4097. doi: 10.1182/bloodadvances.2021005894. PMID: 35482550; PMCID: PMC9327546.

- [TALLSorts](https://github.com/Oshlack/TALLSorts)
  > Oshlack lab. TALLSorts: a T-ALL subtype classifier. https://github.com/Oshlack/TALLSorts

- [MiXCR](https://pubmed.ncbi.nlm.nih.gov/25924071/)
  > Bolotin DA, Poslavsky S, Mitrophanov I, Shugay M, Mamedov IZ, Putintseva EV, Chudakov DM. MiXCR: software for comprehensive adaptive immunity profiling. Nat Methods. 2015 May;12(5):380-1. doi: 10.1038/nmeth.3364.

- [Isofox](https://github.com/hartwigmedical/hmftools/tree/master/isofox)
  > Hartwig Medical Foundation. Isofox: RNA-seq transcript quantification and fusion detection. https://github.com/hartwigmedical/hmftools

- [TEtranscripts](https://pubmed.ncbi.nlm.nih.gov/26206304/)
  > Jin Y, Tam OH, Paniagua E, Hammell M. TEtranscripts: a package for including transposable elements in differential expression analysis of RNA-seq datasets. Bioinformatics. 2015 Nov 15;31(22):3593-9. doi: 10.1093/bioinformatics/btv422.

- [MINTIE](https://pubmed.ncbi.nlm.nih.gov/34686194/)
  > Cmero M, Schmidt B, Majewski IJ, Ekert PG, Oshlack A, Davidson NM. MINTIE: identifying novel structural and splice variants in transcriptomes using RNA-seq data. Genome Biol. 2021 Oct 22;22(1):296. doi: 10.1186/s13059-021-02507-8.

## Software packaging

- [Docker](https://www.docker.com/)
- [Singularity](https://pubmed.ncbi.nlm.nih.gov/28494014/)
  > Kurtzer GM, Sochat V, Bauer MW. Singularity: Scientific containers for mobility of compute. PLoS One. 2017 May 11;12(5):e0177459. doi: 10.1371/journal.pone.0177459.
