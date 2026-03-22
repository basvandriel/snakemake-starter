#!/usr/bin/env python3
"""Count reads in a FASTQ file.

A FASTQ record is 4 lines. This script counts the number of records.

Usage:
    python scripts/count_reads.py input.fastq output.tsv
"""

import os
import sys


def count_reads(inp: str, out: str) -> None:
    with open(inp, "rt") as f:
        # count lines, then divide by 4
        lines = sum(1 for _ in f)
    reads = lines // 4

    sample = os.path.splitext(os.path.basename(inp))[0]

    with open(out, "wt") as f:
        f.write("sample\treads\n")
        f.write(f"{sample}\t{reads}\n")


# Support both `script:` directive (snakemake object injected) and standalone CLI
if "snakemake" in dir():
    os.makedirs(os.path.dirname(snakemake.log[0]), exist_ok=True)  # noqa: F821
    with open(snakemake.log[0], "w") as log:  # noqa: F821
        sys.stdout = log
        sys.stderr = log
        count_reads(snakemake.input[0], snakemake.output[0])  # noqa: F821
else:
    if len(sys.argv) != 3:
        print("Usage: python scripts/count_reads.py <input.fastq> <output.tsv>")
        sys.exit(1)
    count_reads(sys.argv[1], sys.argv[2])
