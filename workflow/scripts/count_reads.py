#!/usr/bin/env python3
"""Count reads in a FASTQ file.

A FASTQ record is 4 lines. This script counts the number of records.

Usage:
    python scripts/count_reads.py input.fastq output.tsv
"""

import os
import sys


def main():
    if len(sys.argv) != 3:
        print("Usage: python scripts/count_reads.py <input.fastq> <output.tsv>")
        sys.exit(1)

    inp = sys.argv[1]
    out = sys.argv[2]

    with open(inp, "rt") as f:
        # count lines, then divide by 4
        lines = sum(1 for _ in f)
    reads = lines // 4

    sample = os.path.splitext(os.path.basename(inp))[0]

    with open(out, "wt") as f:
        f.write("sample\treads\n")
        f.write(f"{sample}\t{reads}\n")


if __name__ == "__main__":
    main()
