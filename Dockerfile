FROM snakemake/snakemake:latest

WORKDIR /pipeline

# Bake all tools into the image. Single source of truth: environment.yaml.
COPY environment.yaml ./
RUN micromamba install -n snakemake -f environment.yaml -y \
    && micromamba clean -afy

COPY . .

ENTRYPOINT ["snakemake", "-s", "workflow/Snakefile"]
CMD ["--cores", "4"]
