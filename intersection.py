from collections import defaultdict
from itertools import combinations
import tqdm
import pysam

# Открываем VCF файл
vcf_file = "data/interim/CARP_KANT.vcf"
vcf = pysam.VariantFile(vcf_file)

# Общее количество вариантов
total_variants = 0

# Создаём словарь для хранения вариантов для каждого семпла
variants_by_sample = defaultdict(set)

for record in tqdm.tqdm(vcf, 'records', 28822046):
    total_variants += 1
    
    # Сохраняем уникальные вариации для каждого семпла
    for sample in record.samples:
        genotype = record.samples[sample]["GT"]  # Генотип
        if genotype[0] is None:
            continue
        v1 = (record.chrom, record.pos, genotype) # debug if len == 3
        v2 = (record.chrom, record.pos, genotype)

        variants_by_sample[sample].add(v1)
        variants_by_sample[sample].add(v2)
    
    # if total_variants > 10000:
    #     break

# print(f"Общее количество вариантов: {total_variants}")


# Считаем различные варианты между семплами
sample_names = list(variants_by_sample.keys())
# difference_count = defaultdict(lambda: defaultdict(int))

print("sample1\tsample2\tcommon\tin1\tin2")

for sample1, sample2 in combinations(sample_names, 2):

    s1 = variants_by_sample[sample1]
    s2 = variants_by_sample[sample2]
    # Различные варианты
    diff1_variants = len(s1.difference(s2))
    diff2_variants = len(s2.difference(s1))
    common_variants = len(s1.intersection(s2))
    # difference_count[sample1][sample2] = len(diff_variants)
    print(f"{sample1.replace('.bam', '')}\t{sample2.replace('.bam', '')}\t{common_variants}\t{diff1_variants}\t{diff2_variants}")
