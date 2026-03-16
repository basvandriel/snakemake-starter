# snakemake-starter

A minimal Snakemake pipeline: aligns FASTQ reads to a reference genome and calls variants.

**Steps:** `bwa mem` → `samtools sort` → `samtools index` → `bcftools call`

## Prerequisites

```bash
uv sync   # install Python deps
```

## Running

### Local (fastest for development)

```bash
uv run snakemake --cores 4
```

### Docker

```bash
make docker-run        # deployed — code baked into image
make docker-dev        # dev — Snakefile live-mounted, edit rules without rebuilding
```

Rebuild after changing `pyproject.toml`:

```bash
make docker-build
```

### Apptainer (HPC / Altair Grid Engine)

Apptainer only runs on Linux. On macOS, test it via a privileged Docker container:

```bash
make apptainer-test          # build .sif + run pipeline
make apptainer-build-local   # build .sif only
make apptainer-run-local     # run pipeline using existing .sif
```

## Output

- `results/mapped/{sample}.bam` — sorted BAM files
- `results/mapped/{sample}.bam.bai` — BAM indices
- `results/variants.vcf` — called variants

## Visualise the DAG

```bash
uv run snakemake --dag | dot -Tsvg > dag.svg   # needs: brew install graphviz
```

