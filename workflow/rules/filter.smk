rule SelectVariants:
    input:
        vcf="results/filtered/all.vcf.gz",
        ref=gatk_dict["ref"],
    output:
        vcf="results/filtered/all.{v}.vcf.gz"
    log:
        "logs/filter/SelectVariants/{v}.log",
    params:
        extra="--select-type-to-include {v}"
    resources:
        mem_mb=1024
    wrapper:
        config["warpper_mirror"]+"bio/gatk/selectvariants"

rule VariantRecalibrator:
    input:
        **gatk_dict,
        vcf="results/filtered/all.{v}.vcf.gz",
    output:
        vcf="results/filtered/all.{v}.vcf",
        idx="results/filtered/all.{v}.vcf.idx",
        tranches="results/filtered/all.{v}.tranches",
    log:
        "logs/filter/VariantRecalibrator/{v}.log",
    params:
        mode="{v}",  # set mode, must be either SNP, INDEL or BOTH
        resources=get_resources,
        annotation=get_annotation,
        extra=get_VRecal_extra,
    threads: 32
    resources:
        mem_mb=2048
    wrapper:
        config["warpper_mirror"]+"bio/gatk/variantrecalibrator"

rule ApplyVQSR:
    input:
        vcf="results/filtered/all.{v}.vcf.gz",
        recal="results/filtered/all.{v}.vcf",
        tranches="results/filtered/all.{v}.tranches",
        ref=gatk_dict["ref"],
    output:
        vcf="results/filtered/ApplyVQSR.{v}.vcf.gz"
    log:
        "logs/filter/ApplyVQSR/{v}.log",
    params:
        mode="{v}",  # set mode, must be either SNP, INDEL or BOTH
        extra=get_truth_sensitivity_filter_level,  # optional
    resources:
        mem_mb=1024
    wrapper:
        config["warpper_mirror"]+"bio/gatk/applyvqsr"

rule merge_filtered:
    input:
        vcfs=expand("results/filtered/ApplyVQSR.{v}.vcf.gz",v=["SNP","INDEL"]),
    output:
        "results/filtered/all.vcf.gz",
    log:
        "logs/filter/merge_filtered.log",
    resources:
        mem_mb=2048
    wrapper:
        config["warpper_mirror"]+"bio/picard/mergevcfs"