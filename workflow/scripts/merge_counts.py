#!/usr/bin/env python3
"""Merge per-sample count TSVs into a single sorted TSV.

Writes the header once and sorts data rows by sample name, making
output deterministic regardless of input file ordering.
"""

import os
import sys


def merge(inputs: list[str], output: str) -> None:
    rows: list[tuple[str, str]] = []

    for path in inputs:
        with open(path) as fh:
            lines = fh.readlines()
        # skip header (first line), collect data rows
        for line in lines[1:]:
            sample = line.split("\t")[0]
            rows.append((sample, line))

    rows.sort(key=lambda r: r[0])

    os.makedirs(os.path.dirname(output), exist_ok=True)
    with open(output, "w") as fh:
        fh.write("sample\treads\n")
        for _, line in rows:
            fh.write(line)


if "snakemake" in dir():
    os.makedirs(os.path.dirname(snakemake.log[0]), exist_ok=True)  # noqa: F821
    with open(snakemake.log[0], "w") as log:
        sys.stderr = log
        merge(list(snakemake.input), snakemake.output[0])  # noqa: F821
else:
    merge(sys.argv[2:], sys.argv[1])
