FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /pipeline

COPY pyproject.toml ./
RUN pip install --no-cache-dir --break-system-packages .

COPY . .

ENTRYPOINT ["snakemake"]
CMD ["--cores", "4"]
