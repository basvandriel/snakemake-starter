SAMPLES = ["A", "B", "C"]


rule all:
    input:
        "results/variants.vcf",


rule bwa_map:
    input:
        ref="data/genome.fa",
        reads="data/samples/{sample}.fastq",
    output:
        "results/mapped/{sample}.bam",
    shell:
        "bwa mem {input.ref} {input.reads} | samtools sort -o {output}"


rule samtools_index:
    input:
        "results/mapped/{sample}.bam",
    output:
        "results/mapped/{sample}.bam.bai",
    shell:
        "samtools index {input}"


rule bcftools_call:
    input:
        ref="data/genome.fa",
        bam=expand("results/mapped/{sample}.bam", sample=SAMPLES),
        bai=expand("results/mapped/{sample}.bam.bai", sample=SAMPLES),
    output:
        "results/variants.vcf",
    shell:
        "bcftools mpileup -f {input.ref} {input.bam} | bcftools call -mv -o {output}"
