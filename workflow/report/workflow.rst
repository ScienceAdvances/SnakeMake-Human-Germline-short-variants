`GATK best practices workflow`_ Pipeline summary

Germline short variants (SNP+INDEL)

=============================================
Reference
=============================================
1. Reference genome related files and GTAK budnle files (GATK_)
2. VEP Variarition annotation files (VEP_)

=============================================
Prepare
=============================================
1. Adapter trimming (Fastp_)
2. Aligner (`BWA mem2`_)
3. Mark duplicates (samblaster_)
4. Generates recalibration table for Base Quality Score Recalibration (BaseRecalibrator_)
5. Apply base quality score recalibration (ApplyBQSR_)

=============================================
Quality control report
=============================================
1. Fastp report (MultiQC_)
2. Alignment report (MultiQC_)

=============================================
Call
=============================================
1. Call germline SNPs and indels via local re-assembly of haplotypes (HaplotypeCaller_)
2. Import VCFs to GenomicsDB (GenomicsDBImport_)
3. Perform joint genotyping on one or more samples pre-called with HaplotypeCaller (GenotypeGVCFs_)

=============================================
Filter
=============================================
1. Select a SNP or INDEL of variants from a VCF file (SelectVariants_)
2. Build a recalibration model to score variant quality for filtering purposes (VariantRecalibrator_)
3. Apply a score cutoff to filter variants based on a recalibration table (ApplyVQSR_)
4. Merge all the VCF files (Picard_)

=============================================
Annotation
=============================================
Annotate variant calls with VEP (VEP_)

.. _GATK best practices workflow: https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows
.. _GATK: https://software.broadinstitute.org/gatk/
.. _VEP: https://www.ensembl.org/info/docs/tools/vep/index.html
.. _fastp: https://github.com/OpenGene/fastp
.. _BWA mem2: http://bio-bwa.sourceforge.net/
.. _samblaster: https://github.com/GregoryFaust/samblaster
.. _BaseRecalibrator: https://gatk.broadinstitute.org/hc/en-us/articles/13832708374939-BaseRecalibrator
.. _ApplyBQSR: https://github.com/GregoryFaust/samblaster
.. _HaplotypeCaller: https://gatk.broadinstitute.org/hc/en-us/articles/13832687299739-HaplotypeCaller
.. _GenomicsDBImport: https://gatk.broadinstitute.org/hc/en-us/articles/13832686645787-GenomicsDBImport
.. _GenotypeGVCFs: https://gatk.broadinstitute.org/hc/en-us/articles/13832766863259-GenotypeGVCFs
.. _SelectVariants: https://gatk.broadinstitute.org/hc/en-us/articles/13832694334235-SelectVariants
.. _VariantRecalibrator: https://gatk.broadinstitute.org/hc/en-us/articles/13832694334235-VariantRecalibrator
.. _ApplyVQSR: https://gatk.broadinstitute.org/hc/en-us/articles/13832694334235-ApplyVQSR
.. _Picard: https://broadinstitute.github.io/picard
.. _MultiQC: https://multiqc.info