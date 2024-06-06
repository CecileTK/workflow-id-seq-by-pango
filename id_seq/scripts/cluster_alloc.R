library(argparse, quietly = T)
library(igraph, quietly = T)
library(tidyverse, quietly = T)

##  Function used to read input / save outputs
collect_args <- function(){
  parser <- ArgumentParser()
  parser$add_argument('--df_id_seq', type = 'character', help = 'Dataframe with pairs of identical sequences')
  parser$add_argument('--cluster_alloc', type = 'character', help = 'File path to store cluster allocation')
  parser$add_argument('--pango', type = 'character', help = 'Pango lineage name')
  return(parser$parse_args())
}

read_df_dist <- function(df_id_seq_path){
  return(
    read_tsv(df_id_seq_path)
  )
}

# Read arguments
args <- collect_args()

# Read dataframe with pairs of identical sequences 
df_identical_sequences <- read_tsv(args$df_id_seq) 


# Get cluster allocation from pairs of identical sequences
get_cluster_alloc_from_df_identical_sequences <- function(df_identical_sequences){
  df_identical_sequences <- df_identical_sequences %>% 
    group_by(strain_1) %>% 
    mutate(n_identical_sequences = n()) %>% 
    mutate(is_singleton = (n_identical_sequences == 1)) %>% 
    ungroup()
  
  vec_strains_singletons <- df_identical_sequences %>% 
    filter(is_singleton) %>% 
    select(strain_1) %>% unique() %>% unlist() %>% as.character()
  
  df_non_singletons <- df_identical_sequences %>% filter(n_identical_sequences > 1)
  
  if(nrow(df_non_singletons) > 0){
    ## Generate the graph asociated to the edge list 
    g_identical <- graph_from_edgelist(el = as.matrix(df_non_singletons[, c('strain_1', 'strain_2')]), directed = F)
    
    ## Get the maximal cliques in g_identical
    max_cliques_identical <- max_cliques(g_identical)
    
    ## Reorder the cliques by increasing size
    size_cliques <- unlist(lapply(max_cliques_identical, length))
    max_cliques_identical <- max_cliques_identical[order(size_cliques)]
    
    ## Get cluster ID member based on maximal cliques
    df_cluster_alloc <- Reduce('bind_rows', lapply(1:length(max_cliques_identical), FUN = function(i_max_clique){
      curr_max_clique <- max_cliques_identical[[i_max_clique]]
      tibble(strain = names(curr_max_clique),
             cluster_id = i_max_clique)
    })) %>% 
      group_by(strain) %>% filter(cluster_id == min(cluster_id)) %>% ungroup()
    
    ## Add singletons
    if(length(vec_strains_singletons) > 0){
      df_cluster_alloc <- df_cluster_alloc %>% 
        bind_rows(tibble(strain = vec_strains_singletons, 
                         cluster_id = (length(max_cliques_identical) + 1):(length(max_cliques_identical) + length(vec_strains_singletons))))
    }
  } else{
    df_cluster_alloc <- tibble(strain = vec_strains_singletons, 
                               cluster_id = 1:length(vec_strains_singletons))
    
  }
  
  return(df_cluster_alloc)
}

if(nrow(df_identical_sequences) > 0){
  df_cluster_alloc <- get_cluster_alloc_from_df_identical_sequences(df_identical_sequences) %>%
    mutate(Nextclade_pango = args$pango)
} else{
  df_cluster_alloc <- data.frame(
    matrix(vector(), 0, 3, 
           dimnames=list(c(), 
                         c("strain","cluster_id","Nextclade_pango"))), 
    stringsAsFactors=F) %>% 
    as_tibble()
}

# Save cluster allocation
write_tsv(df_cluster_alloc, args$cluster_alloc)
