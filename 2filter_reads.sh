# cd data/interim/cor

SAMPLES_FILE=../samples.txt
THREADS=64

PICARD="java -jar /opt/tools/bin/picard.jar"

# 1) filter PCR duplicates
# cat $SAMPLES_FILE | parallel -j 8 $PICARD MarkDuplicates I={}.bam O={.}.marked_duplicates.bam M={.}.marked_dup_metrics.txt

for sample in $(cat $SAMPLES_FILE)
do
    # 2) filter poorly mapped reads
    sambamba view -t $THREADS -f bam -v -F "mapping_quality >= 50" -o $sample.marked_duplicates.mapq50.bam $sample.marked_duplicates.bam

    # Подсчет числа ридов после фильтрации
    sambamba view -c -t $THREADS $sample.marked_duplicates.mapq50.bam > $sample.marked_duplicates.mapq50.bam.rN

    # 3) Наконец, удаление всякого барахла (single reads, unmapped, secondary etc) после фильтрации
    samtools view -@ $THREADS -b -F 3852 $sample.marked_duplicates.mapq50.bam > $sample.marked_duplicates.mapq50.F3852.bam
    
    samtools index $sample.marked_duplicates.mapq50.F3852.bam &

    rm $sample.marked_duplicates.mapq50.bam
    rm $sample.marked_duplicates.mapq50.bam.bai

done
wait
