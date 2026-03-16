rule merge_counts:
    input:
        expand("results/counts/{sample}.tsv", sample=SAMPLES),
    output:
        "results/counts.tsv",
    log:
        "logs/merge_counts.log",
    container:
        "docker://python:3.12",
    shell:
        "mkdir -p $(dirname {log}) && cat {input} > {output} 2> {log}"
