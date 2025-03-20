#!/bin/zsh

# Set working directory
cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data

# Using variables that are passed from the host script
snp_file="$1"
gene_file="processing_data/joined_gene_info.tsv"

# Storing the header name as a variable for comparison
colname="$(head -n 1 "$snp_file")"
exp_colname="$(echo -e "chr\tpos\tsnp")"

# If statement to run script, else check formatting of SNP file
if [[ "$colname" == "$exp_colname" ]];
then
 echo "Processing conjoined SNP and Gene File:"
 # Formatting SNP file for matching
 sed -e 's/Vu0//g ; s/Vu//g' "$snp_file" | tail -n +2 | sort -k1 > processing_data/tmp_snp_file.tsv 
 
 # Creating a start and end column 
 awk '{print $0 "\t" ($2 - 20000) "\t" ($2 + 20000)}' processing_data/tmp_snp_file.tsv > processing_data/counted_regions.tsv
 
 # Creating a While Loop to match corresponding SNPs to Gene IDs
 output="processing_data/combined_snp.tsv"
 while IFS=$'\t' read -r gene_id chr gene start end homolog_id homolog_type gene_name species gene_desc protein_coding; do

    snp_value=""
     
    while IFS=$'\t' read -r chr_s _ snp_s start_s end_s; do
      if [[ "$chr" == "$chr_s" && "$start" -ge "$start_s" && "$end" -le "$end_s" ]]; then
       snp_value="$snp_s"
        break
      fi
     done < processing_data/counted_regions.tsv
   echo -e "$gene_id\t$chr\t$gene\t$start\t$end\t$homolog_id\t$homolog_type\t$gene_name\t$species\t$gene_desc\t$protein_coding\t$snp_value" >> "$output"
 done < "$gene_file"

 # Removing records which do not contain a SNP match, since they are not of interest for GWAS analysis
 awk -F '\t' '$12 != ""' processing_data/combined_snp.tsv > processing_data/tmp.tsv

 # Make directory for output data for easy identification
 mkdir -p output_data

 # Saving only necessary cols (gene_id, chr, start, end, homolog_id, homology_type, gene_desc, snp)
 echo -e "gene_id\tchr\tstart\tend\thomolog_id\thomology_type\tgene_desc\tsnp" > output_data/snps_with_genes_output.tsv
 cut -f1,2,4-7,10,12 processing_data/tmp.tsv | sort -u >> output_data/snps_with_genes_output.tsv
 echo "Job complete"

 # Self cleaning all the temporary files produced by this script
 cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data/processing_data # changing directory into correct directory
 rm -r tmp_snp_file.tsv combined_snp.tsv tmp.tsv counted_regions.tsv
	
else
 echo "Make sure columns are in proper order (chr, pos, snp) and column names are exact matches"
fi
