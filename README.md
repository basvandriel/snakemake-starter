# snakemake-starter

A minimal Snakemake pipeline that aligns FASTQ reads to a reference genome and calls variants.

**Pipeline steps:**
1. Align reads to reference (`bwa mem` + `samtools sort`)
2. Index BAM files (`samtools index`)
3. Call variants (`bcftools mpileup` + `bcftools call`)

## Ways to run

There are three supported workflows:

---

### 1. Local development (recommended for iteration)

Requires system tools installed once:

```bash
brew install bwa samtools bcftools   # macOS
```

Then install Python dependencies and run:

```bash
uv sync
uv run snakemake --cores 4
```

Dry run to preview steps:

```bash
uv run snakemake --cores 4 --dry-run
```

---

### 2. Docker — dev mode (live rule editing, no rebuild needed)

Mounts your local `Snakefile` into the container so you can edit rules and re-run without rebuilding the image:

```bash
docker compose --profile dev up dev
```

Rebuild the image when `pyproject.toml` / `uv.lock` changes:

```bash
docker compose build
```

---

### 3. Docker — deployed (reproducible, self-contained)

Code is baked into the image. Only `data/` and `results/` are mounted. Use this for CI, sharing with collaborators, or running on a remote server:

```bash
docker compose up pipeline          # run
docker compose build                # (re)build image first
```

On a remote server, copy the image with:

```bash
docker save snakemake-starter-pipeline | ssh user@host docker load
```

---

---

### 4. Apptainer (HPC — Altair Grid Engine)

[Apptainer](https://apptainer.org) (the Linux Foundation successor to Singularity) is the standard container runtime on HPC clusters because it doesn't require root.

> **Apptainer only runs natively on Linux** — you can't install it on macOS. However, you can run it inside a **privileged Docker container** for local testing (Docker Desktop on macOS runs containers in a Linux VM, so the kernel requirements are met).

> **Note:** Apptainer ships a `singularity` compatibility symlink, so clusters that haven't updated the module name yet will still work.

#### Testing locally on macOS

```bash
make apptainer-test
```

This spins up `ghcr.io/apptainer/apptainer` with `--privileged`, pulls your image from GHCR, builds a `.sif`, and runs the pipeline — exactly as it would on the HPC cluster.

#### On the actual HPC cluster

Authenticate once:

```bash
echo $CR_PAT | docker login ghcr.io -u basvandriel --password-stdin
```

Then push:

```bash
make docker-push    # builds + tags + pushes to ghcr.io/basvandriel/snakemake-starter-pipeline:latest
```

Or just push to `main` — the GitHub Actions workflow ([.github/workflows/docker.yml](.github/workflows/docker.yml)) builds and pushes automatically.

#### Step 2 — build the `.sif` on the HPC cluster

```bash
make apptainer-build
# equivalent to: apptainer build snakemake-starter-pipeline.sif docker://ghcr.io/basvandriel/snakemake-starter-pipeline:latest
```

#### Step 3 — submit to Altair Grid Engine

```bash
qsub -cwd -V -j y -o logs/pipeline.log run_pipeline.sh
```

Where `run_pipeline.sh` contains:

```bash
#!/usr/bin/env bash
#$ -N snakemake-pipeline
#$ -pe smp 4

apptainer run \
    --bind "$PWD/data:/pipeline/data" \
    --bind "$PWD/results:/pipeline/results" \
    snakemake-starter-pipeline.sif --cores "$NSLOTS"
```

---

### Why not `snakemake/snakemake:stable`?

There is an official Snakemake Docker image (`snakemake/snakemake:stable`). It bundles Snakemake together with a full **Conda/Mamba** stack, because the traditional way to manage per-rule tool dependencies in Snakemake is via `conda:` directives in each rule.

This project uses **uv** instead of Conda, so we don't need any of that:

| | `snakemake/snakemake:stable` | This project |
|---|---|---|
| Package manager | Conda / Mamba | uv |
| Bioinformatics tools (`bwa`, `samtools`, …) | installed via conda | installed via `apt` |
| Python dependencies | conda environment | uv virtual environment |
| Approximate image size | ~1–2 GB | ~300–400 MB |

Use the official image only if you want Snakemake to automatically create isolated conda environments per rule (`conda:` directive). For a uv-based project like this one, a plain Ubuntu base image with apt-installed tools and uv is simpler, faster to build, and smaller.

---

### Visualise the DAG

```bash
uv run snakemake --dag | dot -Tsvg > dag.svg   # needs: brew install graphviz
```

## Output

Results are written to `results/`:
- `results/mapped/{sample}.bam` — sorted BAM files
- `results/mapped/{sample}.bam.bai` — BAM indices
- `results/variants.vcf` — called variants
