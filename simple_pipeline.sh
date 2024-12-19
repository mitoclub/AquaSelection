# Get the reference sequence.
efetch -db=nuccore -format=fasta -id=$ACC | seqret -filter -sid $ACC > $REF

# Index reference for the aligner.
bwa index $REF

# Index the reference genome for IGV
samtools faidx $REF

# Align and generate a BAM file.
bwa mem $REF $R1 $R2 | samtools sort > $BAM

# Index the BAM file.
samtools index $BAM

# Determine the genotype likelihoods for each base. Call the variants with bcftools.
bcftools mpileup -Ou -f $REF $BAM | bcftools call --ploidy 1 -vm -Ov > variants1.vcf
