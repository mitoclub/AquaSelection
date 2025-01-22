#!/bin/bash

# cd data/interim/cor

SAMPLES_FILE=../samples.txt
REF=../../ref/GCF_018340385.1_ASM1834038v1_genomic.fna
THREADS=64


for sample in $(cat $SAMPLES_FILE)
do
    if [[ -f $sample.bam ]]; then
    echo "Pass. BAM file $sample.bam found in the directory"
        continue
    fi

    # Tag the alignments. GATK will only work when reads are tagged.
    TAG="@RG\tID:$sample\tSM:$sample\tPL:ILLUMINA"
    R1=${sample}_1.rp.qt.fq.gz
    R2=${sample}_2.rp.qt.fq.gz
    echo "Processing $R1 $R2"
    
    echo "bwa mem + samtools sort process..." 
    bwa mem $REF $R1 $R2 -t $THREADS -Y -R $TAG | samtools view -bu | samtools sort -m 10G -@ $THREADS -o $sample.bam
    
    # echo "samtools index process..." 
    # samtools index $sample.bam

    echo "samtools stats process..." 
    samtools idxstats --threads $THREADS $sample.bam > $sample.bam.idxstats
    # The output is TAB-delimited with each line consisting of 
    # reference sequence name, sequence length, # mapped read-segments and # unmapped read-segments. 
    # Note this may count reads multiple times if they are mapped more than once or in multiple fragments. 
    
    # coverage=bams/$sample.bam.coverage
    # samtools coverage -in $sample.bam > $sample.bam.coverage

done
