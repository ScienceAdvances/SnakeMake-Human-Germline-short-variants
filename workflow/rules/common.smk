import numpy as np
import pandas as pd
from snakemake.utils import validate
from snakemake.utils import min_version

min_version("7.25.0")

report: "../report/workflow.rst"

# container: "mambaorg/micromamba:1.4.2"

#=====================================================
# validate config.yaml file and samples.csv file
#=====================================================

configfile: "config/config.yaml"

validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], dtype=str,sep='\t',header=0).fillna(value="")

if not "Unit" in samples.columns:
    samples.loc[:,"Unit"]=""
else:
    samples.loc[:,"Unit"] = [f".{x}" for x in samples.Unit]

samples.set_index(keys=["Sample", "Unit"], drop=False,inplace=True)
samples.index = samples.index.set_levels([i.astype(str) for i in samples.index.levels])

validate(samples, schema="../schemas/samples.schema.yaml")

fastqs = config["fastq"].get("dir")
if config["fastq"].get("pe"):
    fq1=[f"{fastqs}/{x}{y}_1.fastq.gz" for x,y in zip(samples.Sample,samples.Unit)]
    fq2=[f"{fastqs}/{x}{y}_2.fastq.gz" for x,y in zip(samples.Sample,samples.Unit)]
    samples.insert(loc=0,column="fq2",value=fq2)
    samples.insert(loc=0,column="fq1",value=fq1)
else:
    fq1=[f"{fastqs}/{x}{y}.fastq.gz" for x,y in zip(samples.Sample,samples.Unit)]
    samples.insert(loc=0,column="fq1",value=fq1)

#=====================================================
# Helper functions
#=====================================================
def get_vep_prefix(config=config):
    g=config["GATK"]
    p="{0}/{1}_{2}_{3}_".format(g['dir'],g['species'].capitalize(),g['build'],g['release'])
    return p

def get_dedup_extra(config=config):
    if config["fastq"]["pe"]:
        return "-M"
    else:
        return "-M --ignoreUnmated"

# def get_intervals(config=config,defalut=""):
#     rr=config["GATK"]["restrict_regions"]
#     if rr:
#         rr=pd.read_csv(rr,sep='\t',header=None,dtype=str)
#     else:
#         return defalut

def get_fastq(wildcards):
	"""Get fastq files of given sample and unit."""
	fastqs = samples.loc[(wildcards.s, wildcards.u,wildcards.g), ]
	if config["fastq"].get("pe"):
		return [fastqs.fq1, fastqs.fq2]
	return [fastqs.fq1]

def get_trimmed_fastq(wildcards):
    """Get trimmed reads of given sample and unit."""
    if config["fastq"].get("pe"):
        # paired-end sample
        return expand(["results/trimmed/{{s}}{{u}}_{_}.fastq.gz"],_=["1","2"])
    # single end sample
    return ["results/trimmed/{s}{u}.fastq.gz"]

def get_read_group(wildcards):
    """Denote sample name and platform in read group."""
    return r"-R '@RG\tID:{s}{u}\tSM:{s}\tLB:{s}\tPL:{pl}'".format(
        s=wildcards.s,
        u=wildcards.u,
        pl=samples.loc[(wildcards.s,wildcards.u),"Platform"]
    )

def get_cram(wildcards):
    """Get all aligned reads of given sample."""
    return expand(
        "results/prepared/{s}{u}.cram",
        s=wildcards.s,
        u=samples.loc[wildcards.s,"Unit"]
    )

def get_cram_idx(wildcards):
    """Get all aligned reads of given sample."""
    return expand(
        "results/prepared/{s}{u}.cram.idx",
        s=wildcards.s,
        u=samples.loc[wildcards.s,"Unit"]
    )

def get_interval_padding(config=config,default=""):
    padding = config["HaplotypeCaller"].get("interval_padding","")
    if padding:
        return "--interval-padding {}".format(padding)
    return default

def get_resources(wildcards,default=""):
    if wildcards.v == "SNP":
        return {
            "hapmap": {"known": False, "training": True, "truth": True, "prior": 15.0},
            "omni": {"known": False, "training": True, "truth": False, "prior": 12.0},
            "g1k": {"known": False, "training": True, "truth": False, "prior": 10.0},
            "dbsnp": {"known": True, "training": False, "truth": False, "prior": 2.0}
        }
    elif wildcards.v == "INDEL":
        return {
            "mills": {"known": False, "training": True, "truth": True, "prior": 12.0},
            "dbsnp": {"known": True, "training": False, "truth": False, "prior": 2.0}
        }
    else:
        return default
def get_annotation(wildcards,default=""):
    if wildcards.v == "SNP":
        return ["QD","MQRankSum","ReadPosRankSum","FS","SOR","DP"] # MQ
    elif wildcards.v == "INDEL":
        return ["QD","DP","FS","SOR","ReadPosRankSum","MQRankSum"]
    else:
        return default
def get_VRecal_extra(wildcards,default=""):
    if wildcards.v == "SNP":
        return "--max-gaussians 4"
    elif wildcards.v == "INDEL":
        return "--max-gaussians 4"
    else:
        return default
def get_truth_sensitivity_filter_level(wildcards,default=""):
    if wildcards.v == "SNP":
        return "--truth-sensitivity-filter-level 99.5"
    elif wildcards.v == "INDEL":
        return "--truth-sensitivity-filter-level 99.0"
    else:
        return default

gatk_dict=dict(ref=config["GATK"]["dir"]+"/Homo_sapiens_assembly38.fasta",
        fai=config["GATK"]["dir"]+"/Homo_sapiens_assembly38.fasta.fai",
        dict=config["GATK"]["dir"]+"/Homo_sapiens_assembly38.dict",
        mills=config["GATK"]["dir"]+"/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz",
        mills_idx=config["GATK"]["dir"]+"/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi",
        omni=config["GATK"]["dir"]+"/1000G_omni2.5.hg38.vcf.gz",
        omni_idx=config["GATK"]["dir"]+"/1000G_omni2.5.hg38.vcf.gz.tbi",
        g1k=config["GATK"]["dir"]+"/1000G_phase1.snps.high_confidence.hg38.vcf.gz",
        g1k_idx=config["GATK"]["dir"]+"/1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi",
        dbsnp=config["GATK"]["dir"]+"/Homo_sapiens_assembly38.dbsnp138.vcf.gz",
        dbsnp_idx=config["GATK"]["dir"]+"/Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi",
        hapmap=config["GATK"]["dir"]+"/hapmap_3.3.hg38.vcf.gz",
        hapmap_idx=config["GATK"]["dir"]+"/hapmap_3.3.hg38.vcf.gz.tbi"
        )
#=====================================================
# Wildcard constraints
#=====================================================

wildcard_constraints:
    v="SNP|INDEL",
    s="|".join(samples.index.get_level_values(0)),
    u="|".join(samples.index.get_level_values(1))