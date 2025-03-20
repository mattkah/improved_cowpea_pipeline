#!/bin/zsh

# Set Wd
cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data

# Making directory for updated data
mkdir -p processing_data

# Filtering Ensembl dataset for specific columns regarding chromosome number, start and end regions of the gene, and gene id
awk '$3 == "gene" {print $1 "\t" $3 "\t" $4 "\t" $5 "\t" $9}' Vigna_unguiculata.ASM411807v1.60.chr.gff3 | \
sed -e 's/ID=gene://g ; s/\;.*//g' > processing_data/filtered_assembly.gff3

# Refining compara data for future manipulations
cut -f1,3-8 Compara_cowpea_homologs_vigna.tsv | tail -n +2 > processing_data/tmp_compara_data.tsv

# Creating Variables
data1="processing_data/filtered_assembly.gff3"
data2="processing_data/tmp_compara_data.tsv"

# Joining filtered_assembly.gff3 and new2.tsv to return a combined file which includes gene location and gene descriptions/homolog info
join -1 5 -2 1 <(sort -k5 "$data1") <(sort -k1 "$data2" | sed 's/ /_/g') | sed 's/ /\t/g' > processing_data/joined_gene_info.tsv

# Cleaning tmp files produced by this script
cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data/processing_data
rm -r filtered_assembly.gff3 tmp_compara_data.tsv
