import json
import sys
from collections import defaultdict

import pandas as pd
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

# need to download human genome, see details in ./data/human_genome/
PATH_TO_GENOME = "./data/ref/GCF_018340385.1_ASM1834038v1_genomic.fna"
PATH_TO_JSON_OUT = "./data/interim/cor/triplet_counts.json"
path_to_intervals = './data/interim/cor/intervals.list'
NUCL_SET = set("ACGTacgt")


def is_appropriate_triplet(triplet: str) -> bool:
    return len(set(triplet).difference(NUCL_SET)) == 0


def main():
    triplet_counts = defaultdict(int)
    fasta = SeqIO.parse(PATH_TO_GENOME, "fasta")

    chr_set = set(pd.read_csv(path_to_intervals, header=None)[0][:-1].to_list())
    rec: SeqRecord = None
    for rec in fasta:
        if rec.description.split()[0] not in chr_set:
            print("Pass", rec.description, file=sys.stderr)
            continue

        print("Processing...", rec.description, file=sys.stderr)
        seq = str(rec.seq)
        # iterate over triplets with window=1
        for i in range(len(seq) - 2):
            triplet = seq[i: i + 3]
            if is_appropriate_triplet(triplet):
                triplet_counts[triplet] += 1

    print(triplet_counts, file=sys.stderr)
    with open(PATH_TO_JSON_OUT, "w") as fout:
        json.dump(triplet_counts, fout)


if __name__ == "__main__":
    main()

