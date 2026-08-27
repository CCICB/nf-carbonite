# nf-carbonite: Usage

## Requirements

- **Nextflow >= 24.10.0** (enforced: the pipeline aborts on older versions)
- **Docker or Singularity** (all tools run in containers)
- The **nf-schema** plugin (`nf-schema@2.5.1`) is downloaded automatically by Nextflow on
  first run. On systems without internet access on compute/login nodes (e.g. NCI Gadi),
  pre-install it once from a machine with internet access:

  ```bash
  nextflow plugin install nf-schema@2.5.1
  ```

  and copy `~/.nextflow/plugins` to the offline system if necessary.

## Samplesheet

`--input` takes a CSV with a header row and one row per sample:

```csv
rnaseq_id,directories
ABC123,/path/to/fastq/files/ABC123
XYZ987,/path/to/fastq/files/XYZ987
```

| Column        | Description                                                                                                  |
| ------------- | ------------------------------------------------------------------------------------------------------------ |
| `rnaseq_id`   | Unique sample identifier. No spaces. Used as the prefix for all output files.                                 |
| `directories` | Path to an existing directory containing that sample's FASTQ files (`*_R1*.gz` / `*_R2*.gz`, paired-end).     |

The samplesheet is validated against [`assets/schema_input.json`](../assets/schema_input.json)
before anything runs: missing columns, duplicate IDs, or non-existent directories fail
immediately with a clear message.

## Parameters

Run `nextflow run CCICB/nf-carbonite --help` for the full parameter listing generated
from the schema. In short:

**Mandatory:** `--input`, `--outdir`, `--reference_name`, `--ref_genome_version`
(`hs38` or `hg19`), `--genome_lib_dir`, `--star_dir`, `--gtf_file`, `--ensg2hgnc_file`.

**Optional (omitting one skips the corresponding tool):** `--rnaindel_dir` (RNAIndel),
`--ensembl_data_dir` (Isofox), `--mixcr_license` (MiXCR), `--te_gtf_file` (TEcount),
`--freebayes_interval_list` (FreeBayes), `--mintie_dir` (MINTIE), `--annovar_dir`
(ANNOVAR), `--gatk_interval_list` (restricts GATK HaplotypeCaller to intervals).

FreeBayes, Isofox and MINTIE only run with `--ref_genome_version hs38`.

Reference paths are best kept in a params file (see `params.yaml` for a template):

```bash
nextflow run CCICB/nf-carbonite \
  --input samples.csv \
  --outdir results \
  -params-file params.yaml \
  -profile docker \
  -resume
```

All parameters are validated against [`nextflow_schema.json`](../nextflow_schema.json)
at startup — misspelled parameters, wrong types, or missing files are reported before
any job is submitted.

## Profiles

| Profile                | Purpose                                                       |
| ---------------------- | ------------------------------------------------------------- |
| `docker`               | Run all processes in Docker containers                        |
| `singularity`          | Run all processes in Singularity containers                   |
| `test`                 | Bundled dummy data for smoke-testing the pipeline wiring      |
| `local`                | Small local overrides                                         |
| `nci`, `pawsey`        | Site profiles for NCI Gadi and Pawsey Setonix (edit the `<project_id>` placeholders first) |
| `cavatica`, `tower`, `s3`, `arm`, `debug` | Platform-specific settings                 |

## Testing

A fast smoke test of the full workflow wiring (no containers or reference data needed —
processes are replaced by their `stub:` blocks). Run it from the repository root:

```bash
nextflow run . -profile test -stub-run --outdir test_results
```

With [nf-test](https://www.nf-test.com) installed, the same check runs as an assertion-based test:

```bash
nf-test test
```

## Resource handling

Default per-process resources live in [`conf/base.config`](../conf/base.config). Processes
that fail with out-of-memory or other transient errors (exit codes 130–145, 104) are
retried up to twice with escalating memory. `resourceLimits` caps requests so retries
never exceed what the environment can schedule; site profiles override the cap for
their clusters. Tools take their thread counts from `task.cpus`, so overriding
`cpus` in a config automatically adjusts tool threading.
