#!/bin/bash

# cd data/interim

SAMPLES_FILE=samples.txt
REF=../ref/GCF_018340385.1_ASM1834038v1_genomic.fna
THREADS=48


for sample in $(cat $SAMPLES_FILE)
do
    # Tag the alignments. GATK will only work when reads are tagged.
    TAG="@RG\tID:$sample\tSM:$sample\tLB:$sample"
    R1=${sample}_1.fq.gz
    R2=${sample}_2.fq.gz
    echo "Processing $R1 $R2"

    BAM=bams/$sample.bam
    idxstats=bams/$sample.bam.idxstats
    coverage=bams/$sample.bam.coverage
    
    echo "bwa mem process..." 
    bwa mem -t $THREADS -R $TAG $REF ../raw/$R1 ../raw/$R2 | samtools sort > $BAM
    
    echo "samtools index process..." 
    samtools index $BAM

    echo "samtools stats process..." 
    samtools idxstats --threads $THREADS $BAM > $idxstats
    bamtools coverage -in $BAM > $coverage

done
