SAMPLES = glob_wildcards("data/samples/{sample}.fastq").sample

rule all:
    input:
        "results/counts.tsv",

rule count_reads:
    input:
        "data/samples/{sample}.fastq",
    output:
        "results/counts/{sample}.tsv",
    params:
        sample="{sample}",
    shell:
        "python scripts/count_reads.py {input} {output}"

rule merge_counts:
    input:
        expand("results/counts/{sample}.tsv", sample=SAMPLES),
    output:
        "results/counts.tsv",
    shell:
        "cat {input} > {output}"
