# cd /data/interim

# WD=/home/kpotoh/carp/data/interim

PICARD="java -jar /opt/tools/bin/picard.jar"

## 1) filter PCR duplicates
# cat samples.txt | parallel -j 8 $PICARD MarkDuplicates I=bams/{}.bam O=bams/{.}.marked_duplicates.bam M=bams/{.}.marked_dup_metrics.txt

## 2) filter poorly mapped reads
sambamba view -p -t 40 -f bam -v -F "mapping_quality >= 50" -o car2493_f.carp1.marked_duplicates.mapq50.bam car2493_f.carp1.marked_duplicates.bam

# Подсчет числа ридов после фильтрации
sambamba view -c -t 40 car2493_f.carp1.marked_duplicates.bam > car2493_f.carp1.marked_duplicates.bam.rN

## 3) Наконец, удаление всякого барахла (single reads, unmapped, secondary etc) после фильтрации
samtools view -@ 40 -b -F 3852 car2493_f.carp1.marked_duplicates.mapq50.bam > car2493_f.carp1.marked_duplicates.mapq50.F3852.bam

## 4) Need to remove reads from non-chromosomal contigs