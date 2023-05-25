rule bwa_mem2:
    input:
        reads=get_trimmed_fastq,
        reference=gatk_dict["ref"],
        idx=multiext(gatk_dict["ref"], ".0123", ".amb", ".bwt.2bit.64", ".ann",".pac"),
    output:
        temp("results/prepared/{s}{u}.aligned.cram") # Output can be .cram, .bam, or .sam
    log:
        "logs/prepare/bwa_mem2/{s}{u}.log"
    params:
        bwa="bwa-mem2", # Can be 'bwa-mem, bwa-mem2 or bwa-meme.
        extra=get_read_group,
        sort="picard",
        sort_order="coordinate",
        dedup=config['fastq'].get('duplicates',"remove"), # Can be 'none' (default), 'mark' or 'remove'.
        dedup_extra=get_dedup_extra(),
        exceed_thread_limit=True,
        embed_ref=True,
    threads: 32
    wrapper:
        config["warpper_mirror"]+"bio/bwa-memx/mem"

rule BaseRecalibrator:
    input:
        bam="results/prepared/{s}{u}.aligned.cram",
        ref=gatk_dict["ref"],
        dict=gatk_dict["dict"],
        known=gatk_dict["dbsnp"],  # optional known sites - single or a list
    output:
        recal_table=temp("results/prepared/{s}{u}.grp")
    log:
        "logs/prepare/BaseRecalibrator/{s}{u}.log"
    resources:
        mem_mb=1024
    params:
        # extra=get_intervals(),  # optional
    wrapper:
        config["warpper_mirror"]+"bio/gatk/baserecalibrator"

rule ApplyBQSR:
    input:
        bam="results/prepared/{s}{u}.aligned.cram",
        ref=gatk_dict["ref"],
        dict=gatk_dict["dict"],
        recal_table="results/prepared/{s}{u}.grp",
    output:
        bam="results/prepared/{s}{u}.cram"
    log:
        "logs/prepare/ApplyBQSR/{s}{u}.log"
    params:
        embed_ref=True  # embed the reference in cram output
    resources:
        mem_mb=2048
    wrapper:
        config["warpper_mirror"]+"bio/gatk/applybqsr"

rule samtools_index:
    input:
        "results/prepared/{s}{u}.cram"
    output:
        "results/prepared/{s}{u}.cram.crai"
    log:
        "logs/prepare/samtools_index/{s}{u}.log"
    threads: 32
    params:
        extra="-c"
    wrapper:
        config["warpper_mirror"]+"bio/samtools/index"