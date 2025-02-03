#!/bin/bash

# cd data/interim/cor

PICARD="java -jar /opt/tools/bin/picard.jar"

REF=/scratch/storageA/carp/ref/GCF_018340385.1_ASM1834038v1_genomic.fna
SAMPLES_FILE=../samples.txt
CHROM_FILE=../CARP_chr.txt
OUTDIR=./gvcfs

mkdir -p $OUTDIR

if [[ ! -f "$SAMPLES_FILE" ]]; then
    echo "Файл не найден: $SAMPLES_FILE"
    exit 1
fi

if [[ ! -f "$CHROM_FILE" ]]; then
    echo "Файл не найден: $CHROM_FILE"
    exit 1
fi

# SAMPLES=("sample1" "sample2" "sample3" "sample4" "sample5" "sample6" "sample7" "sample8" "sample9" "sample10"
#          "sample11" "sample12" "sample13" "sample14" "sample15" "sample16" "sample17" "sample18" "sample19" "sample20"
#          "sample21" "sample22" "sample23" "sample24" "sample25" "sample26" "sample27" "sample28" "sample29" "sample30")
# CHROMS=("chr1" "chr2" "chr3" "chr4" "chr5" "chr6" "chr7" "chr8" "chr9" "chr10" "chr11" "chr12" "chr13" "chr14" "chr15"
#         "chr16" "chr17" "chr18" "chr19" "chr20" "chr21" "chr22" "chrX" "chrY" "chrM")

# gatk --java-options "-Xms24G -Xmx24G" HaplotypeCaller \
    # -I $bam_file -R $REF -O $vcf_file 


# Шаг 1: HaplotypeCaller для каждой хромосомы и каждого образца
# RAM 2Tb and CPU 200 (51*2 jobs)
COUNTER=1
MAX_NSAMPLES=2

# for SAMPLE in $(cat $SAMPLES_FILE); do
for SAMPLE in $(tail -n 26 $SAMPLES_FILE); do
  for CHROM in $(cat $CHROM_FILE); do
    (gatk --java-options "-Xms24G -Xmx24G" \
      HaplotypeCaller \
      -R $REF \
      -I ${SAMPLE}.marked_duplicates.mapq50.F3852.bam \
      -O $OUTDIR/${SAMPLE}.${CHROM}.g.vcf \
      -L $CHROM \
      -ERC GVCF) &
  done

  if [ `expr $COUNTER % $MAX_NSAMPLES` -eq 0 ]; then
    echo WAIT
    wait
  fi
  let COUNTER++

done

if [[ ! -f "$OUTDIR/${SAMPLE}.${CHROM}.g.vcf" ]]; then
    echo "Файл не найден: $OUTDIR/${SAMPLE}.${CHROM}.g.vcf"
    exit 1
fi

# Шаг 2: CombineGVCFs для каждой хромосомы
for CHROM in $(cat $CHROM_FILE); do
  INPUTS=()
  for SAMPLE in $(cat $SAMPLES_FILE); do
    INPUTS+=(--variant $OUTDIR/${SAMPLE}.${CHROM}.g.vcf)
  done

  (gatk CombineGVCFs \
    -R $REF \
    ${INPUTS[@]} \
    -O $OUTDIR/combined.${CHROM}.g.vcf) &
done
wait

if [[ ! -f "$OUTDIR/combined.${CHROM}.g.vcf" ]]; then
    echo "Файл не найден: $OUTDIR/combined.${CHROM}.g.vcf"
    exit 1
fi

# Шаг 3: GenotypeGVCFs для каждой хромосомы
for CHROM in $(cat $CHROM_FILE); do
  (gatk GenotypeGVCFs \
    -R $REF \
    -V $OUTDIR/combined.${CHROM}.g.vcf \
    -O $OUTDIR/cohort.${CHROM}.vcf \
    --pedigree pedigree.gatk.txt \
    --annotation PossibleDeNovo) &
done
wait

if [[ ! -f "$OUTDIR/cohort.${CHROM}.vcf" ]]; then
    echo "Файл не найден: $OUTDIR/cohort.${CHROM}.vcf"
    exit 1
fi

# Шаг 4: Объединение VCF файлов
> input_variant_files.list

for CHROM in $(cat $CHROM_FILE); do
  echo $OUTDIR/cohort.${CHROM}.vcf >> input_variant_files.list
done

$PICARD MergeVcfs I=input_variant_files.list O=cohort.merged.vcf

if [[ ! -f "cohort.merged.vcf" ]]; then
    echo "Файл не найден: cohort.merged.vcf"
    exit 1
fi

# 5
# gatk VariantsToTable \
#     -V cohort.merged.vcf \
#     -O cohort.merged.table \
#     -F CHROM -F POS -F REF -F ALT -F QUAL -F DP -F MQ -F AN \
#     -F hiConfDeNovo -F loConfDeNovo -GF GT -GF DP -GF AD -GF GQ
