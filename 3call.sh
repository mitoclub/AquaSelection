#!/bin/bash

REF=/scratch/storageA/carp/ref/GCF_018340385.1_ASM1834038v1_genomic.fna

# Проверяем, что передан один аргумент
if [ "$#" -ne 1 ]; then
    echo "USAGE: $0 <sample.bam>"
    exit 1
fi

bam_file=$1

if [[ ! -f "$bam_file" ]]; then
    echo "Файл не найден: $bam_file"
    exit 1
elif [[ "$bam_file" != *.bam ]]; then
    echo "Файл должен иметь расширение .bam"
    exit 1
fi

vcf_file="gvcfs/${bam_file%.bam}.HaplotypeCaller.g.vcf"

echo "Input file: $bam_file"
echo "Output file: $vcf_file"

# samtools index $bam_file
gatk --java-options "-Xms24G -Xmx24G" HaplotypeCaller -I $bam_file -R $REF -O $vcf_file \
     -ERC GVCF --heterozygosity 0.05 --indel-heterozygosity 0.05

# ls *.marked_duplicates.bam | parallel -j 32 --dry-run ~/carp/3call.sh {}