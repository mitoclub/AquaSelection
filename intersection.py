import pandas as pd
import tqdm

df = pd.read_parquet('./data/interim/CARP_KANT.parquet')
car_cols = [x for x in df.columns if 'CAR' in x]
child_cols = car_cols[2:]
mother_col = car_cols[0]
father_col = car_cols[1]

print('mother_col:', mother_col)
print('father_col:', father_col)

# transform parents
for c in tqdm.tqdm(car_cols[:2]):
    df[c] = df[c].replace('./.', '').str.split('/')\
        .apply(lambda x: set() if x[0] == '' else set(x))

# d['mother'] = d['mother'].str.split('/').apply(set)
# d['father'] = d['father'].str.split('/').apply(set)
# d['child']  = d['child'].str.split('/').apply(set)
# d
# d.apply(lambda x: [len(x.child.intersection(x.mother)), 
#                    len(x.child.intersection(x.father)),
#                    len(x.child.difference(x.father.union(x.mother)))], axis=1)

handle = open('./data/interim/ident.txt', 'w')
handle.write('sample\tmother\tfather\tdiff\n')
for i, row in tqdm.tqdm(df.iterrows(), 'vatiants', 28822046):
    mother_gt = row[mother_col]
    father_gt = row[father_col]
    parents_gt = father_gt.union(mother_gt)
    for c in child_cols:
        child_gt =  set(row[c].split('/')) if row[c] != './.' else {}
        if len(child_gt) == 0:
            continue
        
        m = len(child_gt.intersection(mother_gt)) if len(mother_gt) else -1
        f = len(child_gt.intersection(father_gt)) if len(father_gt) else -1
        diff = len(child_gt.difference(parents_gt)) if len(mother_gt) and len(father_gt) else -1
        
        handle.write(f'{c.replace("_GT", "")}\t{m}\t{f}\t{diff}\n')


handle.close()