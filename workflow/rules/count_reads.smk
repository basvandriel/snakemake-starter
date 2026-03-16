rule count_reads:
    input:
        "data/samples/{sample}.fastq",
    output:
        "results/counts/{sample}.tsv",
    log:
        "logs/count_reads/{sample}.log",
    container:
        "docker://python:3.12",
    shell:
        "mkdir -p $(dirname {log}) && python workflow/scripts/count_reads.py {input} {output} > {log} 2>&1"
