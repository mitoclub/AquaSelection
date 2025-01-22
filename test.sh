
CHROM_FILE=../CARP_chr.txt
SAMPLES_FILE=../samples.txt
OUTDIR=./gvcfs

COUNTER=1
MAX_NSAMPLES=2
# for SAMPLE in $(cat $SAMPLES_FILE); do
for SAMPLE in $(tail -n 26 $SAMPLES_FILE); do
    for CHROM in $(cat $CHROM_FILE); do
        echo "$SAMPLE-$CHROM"
        

    done
    if [ `expr $COUNTER % $MAX_NSAMPLES` -eq 0 ]; then
        echo WAIT
        # wait
    fi
    let COUNTER++
done
