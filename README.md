# Generating clusters of identical SARS-CoV-2 sequences across a range of datasets on rhino

## Overview

This repository contains the code to generate clusters of identical SARS-CoV-2 sequences for a subset of the overall GISAID dataset by providing a list of filtering commands.
To speed up computations, we only compare sequences within their Nextclade assigned pango lineage.

## Source data

GISAID data were downloaded from the nextstrain-ncov-private S3 bucket on May 3rd, 2024 using the following commands:
```bash
aws configure
aws s3 ls s3://nextstrain-ncov-private
aws s3 cp s3://nextstrain-ncov-private/metadata.tsv.zst data
unzstd data/metadata.tsv.zst
aws s3 cp s3://nextstrain-ncov-private/aligned.fasta.zst data
```

## Setup & installation
We use conda to define an environment containing all the required depencencies.
On rhino, this requires the following steps:

```bash
# Load Anaconda
ml Anaconda3/2023.09-0 

# Ensure that we have the correct conda channels (this only needs to be done once in a session)
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

We can then use conda to install the required dependencies (~ 15 minutes).
The environment can be created and activated using the following commands:
```bash
# Install
conda env create -f envs/idseq.yaml
# Activate
source activate idseq
```

If needed, the environment can be deactivated / deleted using the following command:
```bash
# Deactivate 
conda deactivate
# Remove
conda env remove --name idseq
```

### Running the workflow
The workflow is split into two parts:
- `generate_config` that will list all the pango lineages present in the metadata.
- `id_seq` that will generate clusters of identical sequences for the config defined in `config/config_idseq.yaml` using the pango lineages summarised by the `generate_config` part of the workflow.

### `generate_config`
The workflow can  launched directly from the commandline using:

```bash
# Chaneg the working directory
cd generate_config/

# Activate the environement
source activate idseq

# Ensure snakemake is loaded
ml snakemake/7.18.2-foss-2021b

# Launch workflow
snakemake --use-conda -j 10 --profile ../profiles/
```
### `id_seq`

The workflow can  launched directly from the commandline using:

```bash
# Change the working directory
cd id_seq/

# Activate the environement
source activate idseq

# Ensure snakemake is loaded
ml snakemake/7.18.2-foss-2021b

# Launch workflow
snakemake --use-conda -j 10 --profile ../profiles/
```

or using a bash file to launch a job that will initiate the scheduling (here on the Hutch cluster):

```bash
sbatch launch_schedule.sh
```