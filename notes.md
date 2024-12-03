



## HM:

```bash
Чтобы все ускорить, поставил закачиваться в эту же папку файл CARP_KANT.vcf — в нем есть оба родителя и все их дети из трех экспериментов.
Картирование на геном ASM1834038v1 с mem2:
 
cat CARP_chr.txt | parallel -j 51 --ungroup  "bcftools mpileup --redo-BAQ --min-BQ 30 --per-sample-mF -a DP --threads 4 -f ../REFS/CARP/ASM1834038v1.fna CAR2493_F.bam CAR2494_М.bam CAR2463.bam CAR2464.bam CAR2465.bam CAR2466.bam CAR2467.bam CAR2468.bam CAR2469.bam CAR2470.bam CAR2471.bam CAR2472.bam CAR2473.bam CAR2474.bam CAR2475.bam CAR2476.bam CAR2477.bam CAR2478.bam CAR2479.bam CAR2480.bam CAR2481.bam CAR2482.bam CAR2483.bam CAR2484.bam CAR2485.bam CAR2486.bam CAR2487.bam CAR2488.bam CAR2489.bam CAR2490.bam CAR2491.bam CAR2492.bam -r {} | bcftools call --threads 4 -mv -Ov -o CARP_KANT_{}.vcf"
 
 bcftools concat -Oz -o CARP_KANT.vcf ./vcf/*.vcf
```
В этом файле CARP_KANT.vcf все семплы

FORMAT GT:PL:DP
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=PL,Number=G,Type=Integer,Description="List of Phred-scaled genotype likelihoods">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Number of high-quality bases">


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
