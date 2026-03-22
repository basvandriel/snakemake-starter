# Vision & Architecture Decisions

## Single fat image over per-rule conda environments

Snakemake supports per-rule `conda:` directives that create an isolated environment per rule. This is useful when rules have conflicting dependencies, but it adds significant deployment complexity:

- conda must be present on every target machine / cluster node
- N environments are created at first run (or pre-built separately)
- Each environment is a separate artefact to manage, version, and debug

This project takes a different approach: **one image, all tools**.

All bioinformatics dependencies (`bwa`, `samtools`, `bcftools`, `pysam`, …) are installed into the base conda environment of the official `snakemake/snakemake` Docker image at build time via `environment.yaml`. The resulting image is converted to a single `.sif` file that is the only deployment artefact needed.

```
environment.yaml          ← all tools declared here
     ↓
Dockerfile                ← mamba env update --name base
     ↓
docker build              ← fat image, everything baked in
     ↓
apptainer build           ← snakemake-starter-pipeline.sif
     ↓
apptainer exec *.sif snakemake --cores N
```

No `--use-conda`, no `--use-apptainer` per-rule pulls, no internet access required at runtime.

## Environment layers

| Layer | Tool | Owns |
|-------|------|------|
| Dev | conda + environment.yaml | Everything: Snakemake, bwa, samtools, pytest, … |
| Production | Dockerfile → .sif | environment.yaml baked in — one file on the cluster |

`environment.yaml` is the single source of truth. There is no separate Python package manager — conda handles both the bioinformatics binaries and the Python packages, which avoids duplication and the confusion of two tools managing overlapping dependency sets.

## Why `snakemake/snakemake` as base image?

The official image ships with Snakemake and mamba pre-installed. Using it as a base means:

- Snakemake is not duplicated in `environment.yaml` for the image build
- mamba (faster than conda) is available for installing the remaining tools
- The image is maintained by the Snakemake team and tracks releases

## Trade-offs accepted

| Concern | Decision |
|---------|----------|
| Image size is large | Accepted — standard in bioinformatics |
| All tools share one environment | Acceptable as long as dependencies don't conflict; per-rule envs can be reintroduced if that changes |
| Rebuild required to add a tool | Accepted — adding a tool is a code change and should go through version control and CI anyway |
