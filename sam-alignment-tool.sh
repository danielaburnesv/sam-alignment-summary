#!/usr/bin/env bash

# Creating blank output file
> output.txt

# Defining assembly report as a variable within the script
ar=$(find -type f -name "*assembly_report*.txt")

# Creating a blank array to store the sam file name(s) in the next step
sam_files=()

# Loop to determine if SAM files(s) exists and if so, input names into array sam_files
for f in "$@"; do
# verifies if file exists and makes filter case insensitive
 if [[ -f "$f" &&  "${f,,}" == *.sam ]]; then
  sam_files+=("$f")
 fi
done

# Determining the number of arguments in array sam_files to determine the number of SAM files inputted into script
num_sf=${#sam_files[@]}

# In the case no SAM files are inputted into script, error messaged will be shown in terminal and script will be stopped
if [[ $num_sf -eq 0 ]]; then
 echo "Error: no SAM files found."
 exit 1 # Stops script from running and marks that something went wrong
fi


# ---------------------
# Calculating the total number of reads in inputted sam file(s)
# ---------------------

# Defining funciton to calculate total number of reads and summing the totals if multiple SAM files are inputted
totalreadsf() {
  # Creating local variables within function for the input SAM file and result of calculation
  local samf=$1
  local total=$(samtools view -c $samf)
  # Outputting result
  echo $total
}

# Empty global variable for total reads
total_reads=0

# Loop where totalreads runs for each input SAM file and appends the total after each run of the loop
for ((i=1; i<=num_sf; i++)); do
  # Establishing which SAM file we are working with in each run
  sf="${sam_files[i-1]}"
  # Establishing result_total as the output of totalreadsf with the current SAM file iteration
  result_total=$(totalreadsf $sf)
  # Summing the number of total reads in SAM file(s)
  (( total_reads += $result_total ))
done

# Printing total reads into output file
echo "The total number of reads are $total_reads" >> output.txt


# -------------------
#Calculating total number of aligned reads from SAM file(s)
# -------------------

# Function to count total aligned counts per input SAM file
totalalignedf() {
  local samf=$1
  local total=$(samtools view -c -F 4 $samf)
  echo $total
}

# Empty global variable for total aligned reads
total_aligned=0

# Loop where totalalignedf runs for each of input SAM file and adds appends the total after each run of the loop
for ((i=1; i<=num_sf; i++)); do
  sf="${sam_files[i-1]}"
  result_aligned=$(totalalignedf $sf)
  (( total_aligned += result_aligned ))
done

# Printing total aligned reads into output file
echo "The total number of aligned reads are $total_aligned" >> output.txt


# -------------------
# Calculating the total number of aligned reads per chromosome
# -------------------

# Function to determine the ACC CHR and COUNT based on input SAM file(s) and Assembly Report
ACC_CHR_COUNT() {
  local samf="$1"
  # Calculating ACC and CHR from Assembly Report and storing into local variable
  local ACC_CHR=$(grep -Ev [#] "$ar" | awk '{print $5, $1}' | sort -u)
  # Calculating CHR and COUNT from SAM file
  local CHR_COUNT=$(samtools view -F 4 "$samf" | cut -f 3 | sort | uniq -c | awk '{print $2, $1}')
  # joining results into one table
  local result_acc=$(join <(echo "$ACC_CHR") <(echo "$CHR_COUNT"))
  echo "$result_acc"
}

# Loop through all SAM files and append results into a table and into output file
for ((i=1; i<=num_sf; i++)); do
  sf="${sam_files[i-1]}"
  ACC_CHR_COUNT "$sf"
done | awk '{
  # In the case more than 1 SAM file has been inputted, we are establishing the
  # ACC and CHR as filters to sum the number of counts if those match
  key = $1"\t"$2
  # Summing the number of counts
  count[key] += $3
} END {
  # Printing header of table
  print "ACC\tCHR\tCOUNT"
  # Loop to index each ACC/CHR stored in count array
  # Printing ACC CHR COUNT table
  for (k in count) print k"\t"count[k]
}' | sort -k1,1 >> output.txt # sorts piped output by ACC before appending into output file


# --------------
# Calculating the total execution time of the script
# -------------

echo "The total execution time of the script is $SECONDS seconds." >> output.txt
