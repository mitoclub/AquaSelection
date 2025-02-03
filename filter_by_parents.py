import sys
import pandas as pd
import tqdm

INPUT = sys.argv[1]
OUTPUT = sys.argv[2]

# for debug
# INPUT = 'data/interim/cor/cohort.merged.flt.table.head1k'
# OUTPUT = 'data/interim/cor/cohort.merged.flt.parents.parquet'

mother, father = ['CAR2493_F', 'CAR2494_M']

samples_lst = pd.read_csv('/home/kpotoh/carp/data/interim/samples.txt', header=None)[0].to_list()
print(samples_lst)


def filter_by_PL(pl: list):
    srted = sorted(pl)
    return srted[1] - srted[0] > 20


def filter_by_only_2_AD(ad: list):
    return len(ad) == 2 or 1 <= sum([x > 0 for x in ad]) <= 2


variants = pd.read_csv(INPUT, sep='\t')
print('initial size:', len(variants))

variants = variants[
    (variants[mother+'.GQ'] > 20) &
    (variants[father+'.GQ'] > 20) &
    (variants[mother+'.DP'] > 10) &
    (variants[father+'.DP'] > 10)
]
print('after GQ and DP flt:', len(variants))

for smpl in [father, mother]:
    variants[smpl+'.PL'] = variants[smpl+'.PL'].apply(lambda x: [int(pl) for pl in x.split(',')])
    variants[smpl+'.AD'] = variants[smpl+'.AD'].apply(lambda x: [int(ad) for ad in x.split(',')])

variants = variants[
    (variants[mother+'.PL'].apply(filter_by_PL)) &
    (variants[father+'.PL'].apply(filter_by_PL)) &
    (variants[mother+'.AD'].apply(filter_by_only_2_AD)) &
    (variants[father+'.AD'].apply(filter_by_only_2_AD))
]
print('after PL and AD flt:', len(variants))

for smpl in tqdm.tqdm(samples_lst[:-2], 'PL and AD to lists'):
    variants[smpl+'.PL'] = variants[smpl+'.PL'].apply(lambda x: [int(pl) for pl in x.split(',')])
    variants[smpl+'.AD'] = variants[smpl+'.AD'].apply(lambda x: [int(ad) for ad in x.split(',')])

variants.to_parquet(OUTPUT)
