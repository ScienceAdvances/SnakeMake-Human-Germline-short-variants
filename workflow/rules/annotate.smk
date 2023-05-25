rule annotate_variants:
    input:
        calls="results/filtered/all.vcf.gz",  # .vcf, .vcf.gz or .bcf
        cache=get_vep_prefix()+"vep_cache",  # can be omitted if fasta and gff are specified
        plugins=get_vep_prefix()+"vep_plugins",
        # optionally add reference genome fasta
        # fasta=gatk_dict["ref"],
        # fai=gatk_dict["fai"], # fasta index
        # gff=gatk_dict["gff"],
        # csi=gatk_dict["gff_idx"], # tabix index
        # add mandatory aux-files required by some plugins if not present in the VEP plugin directory specified above.
        # aux files must be defined as following: "<plugin> = /path/to/file" where plugin must be in lowercase
        # revel = path/to/revel_scores.tsv.gz
    output:
        calls="results/vep_annotated.vcf.gz",
        stats=report("report/vep_report.html",
            caption="../report/vep.rst",
            category="VEP Annotation",
        ),
    params:
        # Pass a list of plugins to use, see https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html
        # Plugin args can be added as well, e.g. via an entry "MyPlugin,1,FOO", see docs.
        plugins=config["VEP"].get("plugins",""),
        extra=config["VEP"].get("extra",""),  # optional: extra arguments
    log:
        "logs/annotate/annotate.log"
    threads: 32
    wrapper:
        config["warpper_mirror"]+"bio/vep/annotate"
