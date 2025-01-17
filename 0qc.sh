#!/bin/bash

# cd data/interim

RD=../raw
WD=./cor
REP_DIR=./cor/reports_fastqc

THREADS=64

# cat samples.txt | parallel -j 1 /home/genkvg/bin/bbmap/repair.sh in=$RD/{}_1.fq.gz in2=$RD/{}_2.fq.gz out=$WD/{}_1.rp.fq.gz out2=$WD/{}_2.rp.fq.gz outs=$WD/supl_{}.rp.fq.gz

# cat samples.txt | parallel -j 1 /home/genkvg/bin/bbmap/bbduk.sh  in=$WD/{}_1.rp.fq.gz in2=$WD/{}_2.rp.fq.gz out1=$WD/{}_1.rp.qt.fq.gz out2=$WD/{}_2.rp.qt.fq.gz qtrim=rl trimq=10 ftl=10 minlen=80 # ';' rm $WD/{}_1.rp.fq.gz $WD/{}_2.rp.fq.gz


mkdir -p $REP_DIR


for sample in $(cat samples.txt);
do
    echo $sample

    /home/genkvg/bin/bbmap/repair.sh in=$RD/${sample}_1.fq.gz in2=$RD/${sample}_2.fq.gz out=$WD/${sample}_1.rp.fq.gz out2=$WD/${sample}_2.rp.fq.gz
    
    /home/genkvg/bin/bbmap/bbduk.sh in=$WD/${sample}_1.rp.fq.gz in2=$WD/${sample}_2.rp.fq.gz out1=$WD/${sample}_1.rp.qt.fq.gz out2=$WD/${sample}_2.rp.qt.fq.gz qtrim=rl trimq=10 ftl=10 minlen=80
    
    rm $WD/${sample}_1.rp.fq.gz $WD/${sample}_2.rp.fq.gz

done

fastqc -t $THREADS -o $REP_DIR $WD/CAR24*_*.rp.qt.fq.gz
multiqc $REP_DIR
