echo CANNOT
exit 1

ref_fasta=/scratch/storageA/carp/ref/GCF_018340385.1_ASM1834038v1_genomic.fna

input_bam=$1

gatk BaseRecalibrator \
      -R ${ref_fasta} \
      -I ${input_bam} \
      -O recalibration.table \
      -knownSites ${dbSNP_vcf} \

gatk ApplyBQSR \
    -R ${ref_fasta} \
    -I $input_bam \
    --bqsr-recal-file recalibration.table \
    -O output.bam


TODO where to find -knownSites for CARP?
