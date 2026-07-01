# SAM Alignment Summary Tool

A Bash script for summarizing alignment statistics from one or more SAM files, cross-referenced with a genome Assembly Report. Outputs total reads, total aligned reads, and aligned reads per chromosome to a structured text file.

Developed as a collaborative academic project with Virgilia Olivé as part of the Programming in Bioinformatics Module of the M.Sc. in Bioinformatics at Universitat Autònoma de Barcelona.

---

## Features

- Calculates total number of reads across one or more SAM files
- Calculates total number of aligned reads (excludes unmapped reads using SAM FLAG 4)
- Calculates aligned reads per chromosome, mapped to chromosome names via an NCBI Assembly Report
- Supports multiple SAM files as input, summing counts across files
- Reports total script execution time
- Writes all results to `output.txt`

---

## Requirements

- Bash
- `samtools`
- `awk`, `grep`, `cut`, `sort`, `uniq`, `join` (standard Unix tools)
- An NCBI Assembly Report `.txt` file in the working directory (filename must contain `assembly_report`)

---

## Usage

```bash
bash sam-alignment-tool.sh file1.sam [file2.sam ...]
```

The Assembly Report is detected automatically from the working directory. SAM files are passed as arguments (case-insensitive `.sam` extension matching).

---

## Output

Results are written to `output.txt` in the working directory.

**Example output (single SAM file):**
```
The total number of reads are 368465
The total number of aligned reads are 341858
ACC             CHR     COUNT
CP122175.1      2L      57855
CP122176.1      2R      63220
CP122177.1      3L      73043
CP122178.1      3R      77135
CP122179.1      4       3632
CP122180.1      X       66973
The total execution time of the script is 1 seconds.
```

**Example output (two SAM files):**
```
The total number of reads are 736930
The total number of aligned reads are 683716
ACC             CHR     COUNT
CP122175.1      2L      115710
CP122176.1      2R      126440
CP122177.1      3L      146086
CP122178.1      3R      154270
CP122179.1      4       7264
CP122180.1      X       133946
The total execution time of the script is 2 seconds.
```

---

## Notes

- If no SAM files are passed as arguments, the script exits with an error message
- The Assembly Report must follow NCBI format; chromosome names are extracted from column 1 and accession numbers from column 5
- Output file is overwritten on each run
