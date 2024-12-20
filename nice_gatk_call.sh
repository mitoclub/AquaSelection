#!/bin/bash

# Paths
REF="data/ref/GCF_018340385.1_ASM1834038v1_genomic.fna"
SAMPLES=$(cat data/interim/samples.txt)
CHROMS=$(cat data/interim/CARP_chr.txt)
# SAMPLES=("sample1" "sample2" "sample3" "sample4" "sample5" "sample6" "sample7" "sample8" "sample9" "sample10"
#          "sample11" "sample12" "sample13" "sample14" "sample15" "sample16" "sample17" "sample18" "sample19" "sample20"
#          "sample21" "sample22" "sample23" "sample24" "sample25" "sample26" "sample27" "sample28" "sample29" "sample30")
# CHROMS=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" "chr11" "chr12" "chr13" "chr14" "chr15"
#         "chr16" "chr17" "chr18" "chr19" "chr20" "chr21" "chr22" "chrX" "chrY" "chrM")


# Шаг 1: HaplotypeCaller для каждой хромосомы и каждого образца
for SAMPLE in "${SAMPLES[@]}"; do
  for CHROM in "${CHROMS[@]}"; do
    (gatk HaplotypeCaller \
      -R $REF \
      -I ${SAMPLE}.bam \
      -L ${CHROM}.interval_list \
      -O ${SAMPLE}.${CHROM}.g.vcf \
      -ERC GVCF) &
  done
  wait
done

# Шаг 2: CombineGVCFs для каждой хромосомы
for CHROM in "${CHROMS[@]}"; do
  INPUTS=()
  for SAMPLE in "${SAMPLES[@]}"; do
    INPUTS+=(--variant ${SAMPLE}.${CHROM}.g.vcf)
  done
  (gatk CombineGVCFs \
    -R $REF \
    ${INPUTS[@]} \
    -O combined.${CHROM}.g.vcf) &
done
wait

# Шаг 3: GenotypeGVCFs для каждой хромосомы
for CHROM in "${CHROMS[@]}"; do
  (gatk GenotypeGVCFs \
    -R $REF \
    -V combined.${CHROM}.g.vcf \
    -O cohort.${CHROM}.vcf) &
done
wait

# Шаг 4: Объединение VCF файлов
OUTPUTS=()
for CHROM in "${CHROMS[@]}"; do
  OUTPUTS+=("I=cohort.${CHROM}.vcf")
done

gatk MergeVcfs ${OUTPUTS[@]} -O cohort.merged.vcf
