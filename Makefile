IMAGE_NAME  := snakemake-starter-pipeline
IMAGE_TAG   := latest
SIF         := $(IMAGE_NAME).sif

setup-macos:
	curl -L https://api.github.com/repos/snakemake/snakemake-tutorial-data/tarball -o snakemake-tutorial-data.tar.gz
	tar -xf snakemake-tutorial-data.tar.gz --strip 1 "*/data" "*/environment.yaml"
	mv data resources

setup-linux:
	curl -L https://api.github.com/repos/snakemake/snakemake-tutorial-data/tarball -o snakemake-tutorial-data.tar.gz
	tar --wildcards -xf snakemake-tutorial-data.tar.gz --strip 1 "*/data" "*/environment.yaml"
	mv data resources

# Create the runtime conda environment
conda-env:
	conda env create -f environment.yaml --name snakemake-starter

# Layer dev dependencies on top (pytest, etc.)
conda-env-dev: conda-env
	conda env update --name snakemake-starter -f environment-dev.yaml

run:
	snakemake -s workflow/Snakefile --cores 1

# ── Docker ───────────────────────────────────────────────────────────────────
docker-build:
	docker compose build

docker-run:
	docker compose up pipeline

docker-dev:
	docker compose --profile dev up dev

# Save the Docker image to a local tar file (input for apptainer-build-local)
docker-save: docker-build
	docker save $(IMAGE_NAME):$(IMAGE_TAG) -o $(IMAGE_NAME).tar

# Build the .sif locally on macOS via a privileged Apptainer container
apptainer-build-local: docker-save
	docker compose --profile apptainer up apptainer-build

# Run the pipeline in Apptainer locally (requires .sif from apptainer-build-local)
apptainer-run-local:
	docker compose --profile apptainer up apptainer-run

# Convenience: build .sif then run
apptainer-test: apptainer-build-local apptainer-run-local

.PHONY: setup-macos setup-linux conda-env run docker-build docker-run docker-dev docker-push docker-save apptainer-build apptainer-run apptainer-build-local apptainer-run-local apptainer-test