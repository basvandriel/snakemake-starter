FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bwa \
    samtools \
    bcftools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /pipeline

# Install deps first (cached as long as lockfile doesn't change)
COPY pyproject.toml uv.lock ./
# Copy the full project and wire up the console scripts
COPY . .
RUN uv sync --frozen --no-dev

ENTRYPOINT ["uv", "run", "snakemake"]
CMD ["--cores", "4"]
