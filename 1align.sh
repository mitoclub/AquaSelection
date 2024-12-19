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
    # The output is TAB-delimited with each line consisting of 
    # reference sequence name, sequence length, # mapped read-segments and # unmapped read-segments. 
    # Note this may count reads multiple times if they are mapped more than once or in multiple fragments. 
    
    # samtools coverage -in $BAM > $coverage

done

тут надо добавить софт клиппинг и явный перевод в бам