#!/bin/bash
#SBATCH --job-name=schedule
#SBATCH --output=schedule.o
#SBATCH --error=schedule.e
#SBATCH --time=3-0:0:0

# Activate environment
ml Anaconda3/2023.09-0
source activate idseq

# Load snakemake
ml snakemake/7.18.2-foss-2021b

# Launch workflow
snakemake --use-conda -j 10 --profile ../profiles/ --configfile ../config/config_idseq.yaml
