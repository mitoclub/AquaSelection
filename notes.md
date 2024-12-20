



## HM:

```bash
Чтобы все ускорить, поставил закачиваться в эту же папку файл CARP_KANT.vcf — в нем есть оба родителя и все их дети из трех экспериментов.
Картирование на геном ASM1834038v1 с mem2:
 
cat CARP_chr.txt | parallel -j 51 --ungroup  "bcftools mpileup --redo-BAQ --min-BQ 30 --per-sample-mF -a DP --threads 4 -f ../REFS/CARP/ASM1834038v1.fna CAR2493_F.bam CAR2494_М.bam CAR2463.bam CAR2464.bam CAR2465.bam CAR2466.bam CAR2467.bam CAR2468.bam CAR2469.bam CAR2470.bam CAR2471.bam CAR2472.bam CAR2473.bam CAR2474.bam CAR2475.bam CAR2476.bam CAR2477.bam CAR2478.bam CAR2479.bam CAR2480.bam CAR2481.bam CAR2482.bam CAR2483.bam CAR2484.bam CAR2485.bam CAR2486.bam CAR2487.bam CAR2488.bam CAR2489.bam CAR2490.bam CAR2491.bam CAR2492.bam -r {} | bcftools call --threads 4 -mv -Ov -o CARP_KANT_{}.vcf"
 
 bcftools concat -Ov -o CARP_KANT.vcf ./vcf/*.vcf
```
В этом файле CARP_KANT.vcf все семплы

FORMAT GT:PL:DP
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=PL,Number=G,Type=Integer,Description="List of Phred-scaled genotype likelihoods">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Number of high-quality bases">

## REDO

```bash
cd data/interim/redo

# OC of bams
ls CAR*.marked_duplicates.bam | parallel --dry-run qualimap --java-mem-size=16G bamqc -bam {} -nt 4 -c -outdir results_bamqc_{\.}


# call and filter variants in bcftools
cat ../CARP_chr.txt | parallel --dry-run -j 51 --ungroup  "bcftools mpileup --redo-BAQ --min-BQ 30 -m 3 --per-sample-mF -a DP,AD,QS --threads 4 -f ../../ref/GCF_018340385.1_ASM1834038v1_genomic.fna ../bams/CAR*.marked_duplicates.bam -r {} | bcftools call --threads 4 -mv -Ov -o ./vcf2/carps_{}.vcf"

bcftools concat -Ov -o carps32.vcf ./vcf2/*.vcf

# replace 'M' in header that was pasted as rus letter - 5-7min
bcftools head carps32.vcf | sed 's/CAR2494_М/CAR2494_M/' > carps32.vcf.new
bcftools view -H carps32.vcf >> carps32.vcf.new && rm carps32.vcf && mv carps32.vcf.new carps32.vcf

## select only SNPs
gatk SelectVariants \
     -R ../../ref/GCF_018340385.1_ASM1834038v1_genomic.fna \
     -V carps32.vcf \
     --select-type-to-include SNP \
     -O carps32.SNPs.vcf

# filtration of variants  #7min
gatk VariantFiltration \
    -R ../../ref/GCF_018340385.1_ASM1834038v1_genomic.fna \
    -V carps32.SNPs.vcf \
    -O carps32.SNPs.flt.vcf \
    --filter-name "1st_filter" \
    --filter-expression "QUAL < 20 || MQ < 30"


# gatk VariantFiltration \
#     -R ../../ref/GCF_018340385.1_ASM1834038v1_genomic.fna \
#     -V carps32.SNPs.flt.vcf \
#     -O carps32.SNPs.flt.v2.vcf \
#     --genotype-filter-name "2nd_filter" \
#     --genotype-filter-expression "DP < 5"


# Turn the vcfs to tables for Distributions checking in `prior_vcf_stats.r`
# https://evodify.com/gatk-in-non-model-organism/

#42min
gatk VariantsToTable \
    -V carps32.dnm2.SNPs.vcf \
    -O carps32.dnm2.SNPs.table \
    -F CHROM -F POS -F QUAL -F DP -F MQ -F AN -GF GT -GF DP -GF AD -GF DNM

# gatk VariantsToTable \
#     -V carps32.dnm2.SNPs.vcf.head10k \
#     -O carps32.dnm2.SNPs.table.head10k \
#     -F CHROM -F POS -F QUAL -F DP -F MQ -F AN -GF GT -GF DP -GF AD -GF DNM

# Derive de novo mutations

## test
bcftools head -n 1000 carps32.SNPs.flt.vcf > sample.vcf
bcftools +trio-dnm2 -P ../pedigree.txt --with-pPL -Ov -o test_trios.vcf sample.vcf
bcftools +trio-stats -p ../pedigree.txt -i 'FORMAT/DP>{5,10,15}' test_trios.vcf > test_trio_stats.txt
# -i 'GQ>{10,20,30,40,50}'

## run on full data
bcftools +trio-dnm2 -P ../pedigree.txt -o carps32.dnm2.vcf carps32.vcf
bcftools +trio-stats -p ../pedigree.txt -i 'FORMAT/DP>{5,10,15}' carps32.dnm2.vcf > trio.stats2.txt
bcftools +trio-stats -p ../pedigree.txt -i 'FORMAT/DP>{5,10,15}' carps32.dnm2.SNPs.vcf > trio.stats3.txt
bcftools +mendelian2 carps32.dnm2.SNPs.vcf -i 'FORMAT/DP>5' -P ../pedigree.txt > mendelian.stats.txt

# https://vcftools.sourceforge.net/man_latest.html
vcftools --vcf carps32.dnm2.SNPs.vcf --mendel pedigree.txt.vcftools

# On Muege vcf
bcftools +trio-dnm2 -P pedigree.txt --with-pPL -o CARP_KANT.dnm2.vcf CARP_KANT.vcf

```

## Assess heterozigosity 

https://evodify.com/gatk-in-non-model-organism/

```
Approximate heterozygosity = ((number of sites with Indels)/(Total number of sites))*(1-(average number of homozygous genotypes per site)/(total number of individuals))

# FOR SNPs
x = 3779428/(27851117-6732) * (1 - 12.11/32) = 0.084

# FOR INDEL
x = 3779428/(27851117-6732) * (1 - 11.04/32) = 0.089

select 0.05 for gatk
```

## Trio Calling for de novo Mutations (DNM estimation)

Calls de novo variants using information from a mother, father and child trio

1. varscan https://varscan.sourceforge.net/trio-calling-de-novo-mutations.html
2. bcftools +trio-dnm2 https://samtools.github.io/bcftools/howtos/plugin.trio-dnm2.html
3. bcftools +mendelian https://samtools.github.io/bcftools/howtos/plugin.mendelian.html


## Что сделать

- по генам надо посмотреть де ново мутации
- по бинам покрытия нормализовать сичло ДНМ?
- хороши ли риды?


## Count intersection

```bash
# get total number of variants
bcftools view -H CARP_KANT.vcf | wc -l
# 28822046

#split to 32 separate files
bcftools +split CARP_KANT.vcf.gz -Oz -o separated

# reformat to tabix-like
bcftools view CARP_KANT.vcf -Oz -o CARP_KANT.vcf.gz

# make index of vcf
bcftools index --threads 4 CARP_KANT.vcf.gz

# intersect samples
bcftools isec -p isec_out --threads 4 CARP_KANT.vcf.gz



# filter the variants
# bcftools view -e 'TYPE="indel"' -i 'QUAL>30 && DP>5^C& GQ>20'
vcftools --vcf CARP_KANT.vcf --out SNPs_only --recode --recode-INFO-all --minQ 30 --minDP 5 --minGQ 20 --remove-indels
```

## Run GATK in docker

```bash
docker run --rm -it broadinstitute/gatk:4.1.3.0 -v "$WD":/data 
```

## Pipeline notes

https://www.nature.com/articles/s41598-020-77218-4
The GATK pipeline workflow was applied following best practices (https://software.broadinstitute.org/gatk/best-practices). 
1. The raw paired-end reads were mapped to the GRCH37.37d5 reference genome by BWA-mem v0.7.1537. 
2. Aligned reads were converted to BAM files and sorted based on genome position after marking duplicates using Picard modules. 
3. The raw BAM files were refined by Base Quality Score Recalibration (BQSR) using default parameters. 
4. The variant calling (SNPs and indels) was performed with the HaplotypeCaller module. To speed up efficiency, the whole genome was split into 14 fractions and run in parallel, followed by merging of all runs into a final VCF file. 
5. Additionally, we used Variant Quality Score Recalibration (VQSR) to filter the original VCF files following GATK recommendations for parameter settings: 
HapMap 3.3, Omni 2.5, dbSNP 138, 1000 Genome phase I for SNPs training sets, and Mills- and 1000 Genome phase I data for indels.


https://www.nature.com/articles/s41598-022-05833-4
The GATK pipeline was based on the best practices workflow for germlines established by the Broad Institute (https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels). 
Briefly, reads were aligned to the reference genome using BWA-MEM. 
The human reference genome used here was GRCh37. 
Picard tools were then used to sort and mark PCR duplicate reads, generating BAM files. 
GATK version 4.1.2.0 was used to recalibrate BAM files with BaseRecalibrator and ApplyBQSR and to generate VCF and GVCF files with HaplotypeCaller. 


BaseRecalibrator (BQSR) cannot be used die to abcense of --known-sites
https://gatk.broadinstitute.org/hc/en-us/articles/360036898312-BaseRecalibrator


Filtering recommendations

VariantRecalibrator also cannot be used in Carp due to absence of reference set of variants like HapMap
This tool performs the first pass in a two-stage process called Variant Quality Score Recalibration (VQSR). Specifically, it builds the model that will be used in the second step to actually filter variants. This model attempts to describe the relationship between variant annotations (such as QD, MQ and ReadPosRankSum, for example) and the probability that a variant is a true genetic variant versus a sequencing or data processing artifact. It is developed adaptively based on "true sites" provided as input, typically HapMap sites and those sites found to be polymorphic on the Omni 2.5M SNP chip array (in humans). This adaptive error model can then be applied to both known and novel variation discovered in the call set of interest to evaluate the probability that each call is real. The result is a score called the VQSLOD that gets added to the INFO field of each variant. This score is the log odds of being a true variant versus being false under the trained Gaussian mixture model. 

!!!!!!!!!!
https://gatk.broadinstitute.org/hc/en-us/articles/360035532412-Can-t-use-VQSR-on-non-model-organism-or-small-dataset
!!!!!!!!!!
Here are some recommended arguments to use with VariantFiltration when ALL other options are unavailable to you. Be sure to read the documentation explaining how to understand and improve upon these recommendations.

Note that these JEXL expressions will tag as filtered any sites where the annotation value matches the expression. So if you use the expression QD &lt; 2.0, any site with a QD lower than 2 will be tagged as failing that filter.
For SNPs:

    QD < 2.0
    MQ < 40.0
    FS > 60.0
    SOR > 3.0
    MQRankSum < -12.5
    ReadPosRankSum < -8.0

For indels:

    QD < 2.0
    ReadPosRankSum < -20.0
    InbreedingCoeff < -0.8
    FS > 200.0
    SOR > 10.0

## Tools

- SnpEff and ANNOVAR


## References

1. https://www.nature.com/articles/s41598-022-15563-2 - BCFtools is better than GATK for non-human species. Hard Filtering in GATK was performed with the following criterion: **QD < 2, FS > 60, MQ < 40, MQRankSum < − 12.5, ReadPosRankSum < − 8**. FOR BCFTOOLS  only SNVs were collected. Filtering was performed by discarding SNVs in which the variant calling score at **QUAL field is lower than 20**.
2. https://bmcbiol.biomedcentral.com/articles/10.1186/s12915-023-01806-9#Sec10 - pipeline with nice description. Maybe it is the best for us
3. https://pmc.ncbi.nlm.nih.gov/articles/PMC10083221/#s02 - GWAS on carp and gatk pipeline with hard filtering (VariantFiltration with the parameters “**QD<2.0 || QUAL<30.0 || SOR>3.0 || FS>20.0 || MQ<40.0 || MQRankSum<−12.5 || ReadPosRankSum<−8.0**”. The VCF files were then filtered with the parameters “–max-alleles 2 –min-alleles 2 –maf 0.05 –max-missing 0.8” using VCFtools (v1.15) (Danecek et al., 2011). The final dataset was purged by PLINK (v1.90) (Purcell et al., 2007) with the parameters “–indep-pairwise 100 1 0.5”, reducing the redundant highly linked SNPs)
4. https://www.sciencedirect.com/science/article/pii/S294979812400019X#sec2 - gatk pipeline with hard filtering (QD ​< ​2.0, FS ​> ​60.0, MQ ​< ​30.0, HaplotypeScore > 13.0, MappingQualityRankSum ​< ​−12.5, and ReadPosRankSum ​< ​−8.0) AND GWAS AND annotation with annovar
5. https://sci-hub.ru/10.1038/nature24018 DNMs in human Iceland
6. https://www.nature.com/articles/ncomms6969#Sec9 DNMs in Danish trios
7. https://genomemedicine.biomedcentral.com/articles/10.1186/s13073-020-00791-w review of variant calling