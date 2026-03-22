rule count_reads:
    input:
        "resources/samples/{sample}.fastq",
    output:
        "results/counts/{sample}.tsv",
    log:
        "logs/count_reads/{sample}.log",
    container:
        "docker://python:3.12",
    script:
        "../scripts/count_reads.py"
