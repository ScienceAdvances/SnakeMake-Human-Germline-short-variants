rule get_GATK_bundle:
    output:
        **gatk_dict
    conda:
        "../envs/get_GATK_bundle.yaml"
    retries: 2
    threads: 32
    log: 
        "logs/ref/get_GATK_bundle.log"
    script:
        "../scripts/get_GATK_bundle.py"

rule bwa_mem2_index:
    input:
        gatk_dict["ref"]
    output:
        multiext(
            gatk_dict["ref"],
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac",
        ),
    log:
        "logs/ref/bwa_mem2_index.log"
    params:
        bwa="bwa-mem2"
    threads: 32
    cache: True
    wrapper:
        config["warpper_mirror"]+"bio/bwa-memx/index"

rule get_vep_cache:
    output:
        directory(get_vep_prefix()+"vep_cache"),
    params:
        species=config["GATK"].get("species","homo_sapeins"),
        build=config["GATK"].get("build","GRCh38"),
        release=config["GATK"].get("release","109"),
    retries: 50
    log:
        "logs/ref/get_vep_cache.log"
    cache: True
    wrapper:
        config["warpper_mirror"]+"bio/vep/cache"

rule get_vep_plugins:
    output:
        directory(get_vep_prefix()+"vep_plugins")
    retries: 50
    params:
        config["GATK"].get("release","109")
    log:
        "logs/ref/get_vep_plugins.log"
    cache: True
    shell:
        "(git clone -b release/{params} --single-branch https://jihulab.com/BioQuest/vep_plugins.git {output}) {log}"