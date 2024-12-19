# cd /data/interim

# WD=/home/kpotoh/carp/data/interim

PICARD="java -jar /opt/tools/bin/picard.jar"

cat samples.txt | parallel -j 8 $PICARD MarkDuplicates I=bams/{}.bam O=bams/{.}.marked_duplicates.bam M=bams/{.}.marked_dup_metrics.txt

# WD=bams
# for BAM in `cat samples.txt`; 
# do
#     echo "Processing $BAM"
#     bn=$(basename $BAM .bam)
#     OUT=$WD/$bn.marked_duplicates.bam
#     M=$WD/$bn.marked_dup_metrics.txt
#     $PICARD MarkDuplicates I=$BAM O=$OUT M=$M

# done
