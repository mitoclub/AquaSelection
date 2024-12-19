#!/bin/bash

PICARD="java -jar /opt/tools/bin/picard.jar"

ls *.marked_duplicates.HaplotypeCaller.vcf > _input_variant_files.list

$PICARD MergeVcfs INPUT=_input_variant_files.list OUTPUT=carps32.g.vcf.gz