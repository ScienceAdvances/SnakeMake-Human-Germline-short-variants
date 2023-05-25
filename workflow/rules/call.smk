rule HaplotypeCaller:
    input:
        bam=get_cram,
        map_idx=get_cram_idx,
        ref=gatk_dict["ref"],
        known=gatk_dict["dbsnp"],
        intervals=config["fastq"].get("restrict_regions","")
    output:
        gvcf="results/called/{s}.gvcf.gz"
    # 	bam="{sample}.assemb_haplo.bam",
    log:
        "logs/called/HaplotypeCaller/{s}.log",
    params:
        extra=get_interval_padding()
    threads: 32
    resources:
        mem_mb=2048
    wrapper:
        config["warpper_mirror"]+"bio/gatk/haplotypecaller"

rule GenomicsDBImport:
    input:
        gvcfs=expand(
            "results/called/{s}.gvcf.gz", 
            s=samples.index.get_level_values(0)
        ),
        intervals=config["fastq"].get("restrict_regions","")
    output:
        db=directory("results/called/db")
    log:
        "logs/call/GenomicsDBImport.log"
    params:
        db_action="create"
    resources:
        mem_mb=lambda wildcards, input: max([input.size_mb * 1.6, 200]),
    wrapper:
        config["warpper_mirror"]+"bio/gatk/genomicsdbimport"

rule GenotypeGVCFs:
    input:
        # gvcf="results/called/all.{contig}.g.vcf.gz",  # combined gvcf over multiple samples
        genomicsdb="results/called/db",
        ref=gatk_dict["ref"],
        intervals=config["fastq"].get("restrict_regions","")
    output:
        vcf="results/called/all.vcf.gz"
    log:
        "logs/called/GenotypeGVCFs.log"
    resources:
        mem_mb=1024
    wrapper:
        config["warpper_mirror"]+"bio/gatk/genotypegvcfs"