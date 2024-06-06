library(argparse, quietly = T)
library(tidyverse, quietly = T)

##  Function used to read input / save outputs
collect_args <- function(){
  parser <- ArgumentParser()
  parser$add_argument('--metadata', type = 'character', help = 'Metadata files')
  parser$add_argument('--dir_strain_names', type = 'character', help = 'Directory to save all the strain names')
  return(parser$parse_args())
}

# Read arguments
args <- collect_args()

# Read metadata file
metadata <- read_tsv(args$metadata)

# Get list of Pango lineages names
vec_pango <- 