rule fastp_multiqc:
    input:
        expand("report/{s}{u}.fastp.json", s=samples.Sample,u=samples.Unit)
    output:
        report(
            "report/fastp_multiqc.html",
            caption="../report/multiqc.rst",
            category="Quality control"
        ),
    log:
        "logs/qc/fastp_multiqc.log"
    wrapper:
        config["warpper_mirror"]+"bio/multiqc"

rule samtools_stats:
    input:
        bam="results/prepared/{s}.cram",
        bed=config["GATK"].get("restrict_regions",""),#Optional input, specify target regions
    output:
        temp("results/prepared/{s}.txt")
    log:
        "logs/qc/{s}.samtools_stats.log"
    wrapper:
        config["warpper_mirror"]+"bio/samtools/stats"

rule bwa_multiqc:
    input:
        expand("results/prepared/{s}.txt",s=samples.Sample),
    output:
        report(
            "report/prepare_multiqc.html",
            caption="../report/multiqc.rst",
            category="Quality control",
        ),
    log:
        "logs/qc/prepare_multiqc.log",
    wrapper:
        config["warpper_mirror"]+"bio/multiqc"