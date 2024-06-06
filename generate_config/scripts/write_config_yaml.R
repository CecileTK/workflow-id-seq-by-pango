library(tidyverse, quietly = T)
library(yaml, quietly = T)
library(argparse, quietly = T)

##  Function used to read input / save outputs
collect_args <- function(){
  parser <- ArgumentParser()
  parser$add_argument('--pango_names', type = 'character', help = 'List of pango names')
    parser$add_argument('--scenario', type = 'character', help = 'Scenario name')
  parser$add_argument('--config', type = 'character', help = 'Output file for yaml')
  return(parser$parse_args())
}

# Read arguments
args <- collect_args()

# Read names of pango lineages
vec_pango <- read.table(args$pango_names) 

# Add attribute name
vec_pango_list <- list(unlist(vec_pango) %>% as.character())
names(vec_pango_list) <- args$scenario

# Save config file
write_yaml(vec_pango_list, file = args$config)
