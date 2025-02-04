
# http://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html#gff
# USE VEP for annotation
# ANNOVAR is SHIT

cd data/interim/cor
# dnm_locations.tsv file derived after DNM estimation in intersect.ipynb
vcftools --vcf cohort.merged.flt.snpgap.vcf --positions dnm_locations.tsv \
  --recode --out cohort.merged.flt.snpgap.dnm_gatk
cd -

# prepare gff in required format (vep version 105)
cd data/ref
grep -v "#" GCF_018340385.1_ASM1834038v1_genomic.gff | sort -k1,1 -k4,4n -k5,5n -t$'\t' | bgzip -c > data.gff.gz
tabix -p gff data.gff.gz

# INPUT=../interim/cor/sample.vcf
# OUTPUT=../interim/cor/sample.annotated.tsv

INPUT=../interim/cor/cohort.merged.flt.snpgap.dnm_gatk.recode.vcf
OUTPUT=../interim/cor/cohort.merged.flt.snpgap.dnm_gatk.annotated.tsv

vep -i $INPUT -o $OUTPUT --gff data.gff.gz --fasta GCF_018340385.1_ASM1834038v1_genomic.fna --tab