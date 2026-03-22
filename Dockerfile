FROM snakemake/snakemake:latest

WORKDIR /pipeline

# Bake all bioinformatics tools into the image on top of the official Snakemake base.
# This produces a single self-contained image — no per-rule conda or container
# downloads needed at runtime.
COPY environment.yaml ./
RUN mamba env update --name base --file environment.yaml \
    && mamba clean -afy

COPY . .

ENTRYPOINT ["snakemake", "-s", "workflow/Snakefile"]
CMD ["--cores", "4"]
