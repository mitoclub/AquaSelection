
# cd data/interim/cor

gatk VariantFiltration \
   -R ../../ref/GCF_018340385.1_ASM1834038v1_genomic.fna \
   -V cohort.merged.vcf \
   -O cohort.merged.flt.vcf \
   --filter-name "QD_filter" \
   --filter-expression "QD < 2.0" \
   --filter-name "FS_filter" \
   --filter-expression "FS > 60.0" \
   --filter-name "MQ_filter" \
   --filter-expression "MQ < 50.0" \
   --filter-name "MQRankSum_filter" \
   --filter-expression "MQRankSum < -5.0 || MQRankSum > 5.0" \
   --filter-name "ReadPosRankSum_filter" \
   --filter-expression "ReadPosRankSum < -8.0 || ReadPosRankSum > 8.0" \
   --filter-name "SOR_filter" \
   --filter-expression "SOR > 3.0"


gatk VariantsToTable \
    -V cohort.merged.flt.vcf \
    -O cohort.merged.flt.table \
    -F CHROM -F POS -F TYPE -F hiConfDeNovo -GF GT -GF DP -GF AD -GF PL -GF GQ
