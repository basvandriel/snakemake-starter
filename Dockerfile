FROM snakemake/snakemake:latest

WORKDIR /pipeline

# Bake all tools into the image. Single source of truth: environment.yaml.
COPY environment.yaml ./
RUN mamba env update --name base --file environment.yaml \
    && mamba clean -afy

COPY . .

ENTRYPOINT ["snakemake", "-s", "workflow/Snakefile"]
CMD ["--cores", "4"]
