#!/bin/zsh

# Set working directory
cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data

# Using variables that are passed from the host script
snp_file="$1"

# Joined data from the merging gene info script (001)
gene_file="processing_data/joined_gene_info.tsv"

# Storing the header name as a variable for comparison
colname="$(head -n 1 "$snp_file" | tr -d '\r')"  # Remove \r from the header
exp_colname="$(echo -e "chr\tsnp\tbp\tp_lrt")"

# If statement to run script, else check formatting of SNP file
if [[ "$colname" == "$exp_colname" ]];
then
 echo "Processing conjoined SNP and Gene File:"
 sed -e 's/Vu0//g ; s/Vu//g' "$snp_file" | tail -n +2 | sort -k1 > processing_data/tmp_file.tsv # Removing the Vu prefix from the chr column and removing the header for matching

 # Since there are repeating SNP IDs, this filters for the lowest p_ltr (highest SNP significance) and keeps it. Non-unique SNP records are then removed 
 output_file="processing_data/tmp_new.tsv"

 # Loop over unique SNPs and process the p_lrt values
 awk -F '\t' '{print $2}' processing_data/tmp_file.tsv | sort -u | while read snp; do

   max=1  # Start with a high max value for p_lrt
   low=""

   # Find the row with the minimum p_lrt for each SNP
   low=$(awk -F '\t' -v snp="$snp" -v max="$max" '
     $2 == snp {  # Match SNP ID in column 2
       if ($5 < max) { 
         max = $5
         low = $0  # Store the entire line with the lowest p_lrt
       }
     }
     END {print low}' processing_data/tmp_file.tsv)

   # Append the lowest p_lrt row to the output file
   echo "$low" >> "$output_file"
 done

 # After using p_ltr values to filter most significant SNPs, we can remove the p_ltr column
 cut -f1-3 processing_data/tmp_new.tsv > processing_data/tmp1.tsv 
 
 # Adding start and end region of the SNP by +-20 kb
 awk '{print $0 "\t" ($3 - 20000) "\t" ($3 + 20000)}' processing_data/tmp1.tsv > processing_data/tmp_counted_regions.tsv

 # Creating a While Loop to match corresponding SNPs to Gene IDs
 output="processing_data/combined_snp.tsv"
  while IFS=$'\t' read -r gene_id chr gene start end homolog_id homolog_type gene_name species gene_desc protein_coding; do

    snp_value=""

    while IFS=$'\t' read -r chr_s snp_s _ start_s end_s; do
      if [[ "$chr" == "$chr_s" && "$start" -ge "$start_s" && "$end" -le "$end_s" ]]; then
       snp_value="$snp_s"
        break
      fi
     done < processing_data/tmp_counted_regions.tsv
   echo -e "$gene_id\t$chr\t$gene\t$start\t$end\t$homolog_id\t$homolog_type\t$gene_name\t$species\t$gene_desc\t$protein_coding\t$snp_value" >> "$output"
 done < "$gene_file"

 # Removing records which do not contain a SNP match, since they are not of interest for GWAS analysis
 awk -F '\t' '$12 != ""' processing_data/combined_snp.tsv > processing_data/tmp.tsv

 # Make directory for output data for easy identification
 mkdir -p output_data

 # Saving only necessary cols (gene_id, chr, start, end, homolog_id, homology_type, gene_desc, snp)
 echo -e "gene_id\tchr\tstart\tend\thomolog_id\thomology_type\tgene_desc\tsnp" > output_data/signif_snps_with_genes_output.tsv
 cut -f1,2,4-7,10,12 processing_data/tmp.tsv | sort -u >> output_data/signif_snps_with_genes_output.tsv
 echo "Job complete"
 
 # Self cleaning
 cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data/processing_data # set wd to new directory
 rm -r tmp_new.tsv tmp_file.tsv tmp1.tsv combined_snp.tsv tmp.tsv tmp_counted_regions.tsv

else
 echo "Error: Make sure columns are in proper order (chr, snp, bp, p_lrt) and that column names are exact matches"
fi
