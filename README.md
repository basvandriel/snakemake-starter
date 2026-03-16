# snakemake-starter

A minimal Snakemake pipeline: counts reads in FASTQ files and writes a simple TSV report.

**Project layout:**

- `workflow/` → Snakemake workflow (rules, scripts, notebooks, reports)
- `config/` → configuration files (e.g., `config.yaml`, sample sheets)
- `data/` → input data (FASTQ, reference)
- `results/` → pipeline outputs (counts, variants, etc.)

**Steps:** `count_reads.py` → per-sample TSV → merge into `results/counts.tsv`

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

This project can run on a cluster using Apptainer (the modern Singularity).

To avoid building the `.sif` on macOS or native on Windows (Apptainer is Linux-only), you can build and test locally via Docker:

```bash
make apptainer-test          # build .sif + run pipeline (macOS)
make apptainer-build-local   # build .sif only (macOS)
make apptainer-run-local     # run pipeline using existing .sif (macOS)
```

### Deploying to an HPC cluster (registry-based flow)

1) Build the Docker image locally:

```bash
make docker-build
```

2) Push it to a registry (GHCR by default):

```bash
docker push <image>
```

3) On the cluster, build the `.sif` from the registry image:

```bash
apptainer build snakemake-starter-pipeline.sif docker://ghcr.io/basvandriel/snakemake-starter-pipeline:latest
```

4) Run the pipeline:

```bash
apptainer exec \
  --pwd /pipeline \
  --bind "$PWD/data:/pipeline/data" \
  --bind "$PWD/results:/pipeline/results" \
  --bind "$PWD/.snakemake:/pipeline/.snakemake" \
  snakemake-starter-pipeline.sif \
  snakemake --cores "$NSLOTS"
```

### High-level flow (registry-based)

```mermaid
flowchart LR
  A[Local dev] -->|build & push| B[Registry]
  B -->|pull| C[HPC cluster]
  C -->|build .sif| D[Apptainer image]
  D -->|run| E[Snakemake pipeline]
```
