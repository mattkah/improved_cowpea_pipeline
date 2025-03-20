001_joining_gene_desc_with_loci.sh
Joins two files together using a gene IDs. A description of the files is given below:

- Compara_cowpea_homologs_vigna.tsv - gene info such as gene description, homolog ID, and homolg type
- Vigna_unguiculata.ASM411807v1.60.chr.gff3 - gene loci info such as chromosome and start and end region of a gene

002_matching_snp_with_gene_loci.sh 
Depending on the column amount, either len_04_filter.sh or len_05_filter.sh is run. The reason for column amount discrepancies is due to  non-unique SNP values provided, in which case the script keeps the SNP with the lowest p_lrt value.

Note: this script requires 3 data files in the data directory:
1. Compara_cowpea_homologs_vigna.tsv (name must be equal to this)
2. Vigna_unguiculata.ASM411807v1.60.chr.gff3 (name must be equal to this) 
3. SNP file of choice, either 4 or 5 cols (can be named anything) 

len_04_filter.sh
Script is ran when there are 4 columns in the following order:  chr, start, end, snp (colnames must also match). Matches genes where their bp ranges falls within the +-20 kb range of the SNP.

len_05_filter.sh
Script is run if there are 5 columns present in the following order: chr, snp, start, end, p_lrt (colnames also must match). First filters for lowest p_lrt value, then matches genes where their bp ranges falls with +-20 kb of the SNP.