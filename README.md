# Generating clusters of identical SARS-CoV-2 sequences 

## Description
This repository provides the tools to generate pairwise distance matrices for a SARS-CoV-2 sequence dataset within each pango lineage.

## Input data
GISAID data were downloaded from the nextstrain-ncov-private S3 bucket on May 3rd, 2024 using the following commands:
```bash
aws configure
aws s3 ls s3://nextstrain-ncov-private
aws s3 cp s3://nextstrain-ncov-private/metadata.tsv.zst data
unzstd data/metadata.tsv.zst
aws s3 cp s3://nextstrain-ncov-private/aligned.fasta.zst data
```
