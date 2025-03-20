#!/bin/zsh

# Set Wd
cd /Users/mattkahler/Desktop/cowpea_test/update_rda/data

# Capturing SNP file and saving it as a variable
snp_file=""

# Flag to check if SNP file is found
found_snp_file=false

# Flag to ensure only 3 files of data
file_count="$(find . -type f -maxdepth 1 | wc -l)"

if [[ "$file_count" -eq 3 ]];
then
# Check for correct file
for file in *; do
  if [[ -f "$file" && "$file" != "Compara_cowpea_homologs_vigna.tsv" && "$file" != "Vigna_unguiculata.ASM411807v1.60.chr.gff3" ]]; then
    snp_file="$file"  # Save other file as snp_file
    len="$(awk -F '\t' '{print NF; exit}' "$snp_file")" # Get number of columns of SNP input file and store in len

    # Check the number of columns
    if [[ "$len" -eq 5 ]]; then
      echo "Processing data with 5 columns"
      found_snp_file=true

      # Running script that will correctly format SNP input data with 5 cols (5 cols = multiple similar SNP IDs, filtering by the lowest p-value - highest SNP significance)
      /Users/mattkahler/Desktop/cowpea_test/update_rda/len_05_filter.sh "$snp_file"      

      break
    elif [[ "$len" -eq 4 ]]; then
      echo "Processing data with 4 columns"
      found_snp_file=true
      
      # Running script that will correctly format SNP input data with 4 cols
      /Users/mattkahler/Desktop/cowpea_test/update_rda/len_04_filter.sh "$snp_file"

      break
    else
      echo "Make sure there is the correct amount of cols in the SNP file provided. Number of cols should be 4 or 5. For more info, see the README.md"
      found_snp_file=true
      break
    fi
  fi
done

# If no SNP file is found
if [[ "$found_snp_file" == false ]]; then
  echo "Please provide SNP file"
fi
elif [[ "$file_count" -lt 3 ]]; then
 echo "Fewer than 3 files detected. Please make sure Compara, Vigna, and SNP file of choice is provided to the data directory."
elif [[ "$file_count" -gt 3 ]]; then
 echo "More than 3 files detected. Remove any files that are not Compara, Vigna, or the SNP file of choice from the data directory." 
fi
