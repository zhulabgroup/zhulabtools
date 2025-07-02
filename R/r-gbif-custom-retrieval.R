

#' Custom GBIF Data Retrieval
#'
#' This function retrieves the GBIF data and writes it into separate files based
#' on taxonomic ranks (species and genus). It first reads the taxonomy data and
#' then filters and writes the data for species and genus into different directories.
#'
#' @param taxonomy_file_path The path to the taxonomy file (RDS format) containing
#'   the taxonomic information.
#' @param data_file_path The path to the directory containing the GBIF occurrence data.
#' @param species_dir_path The directory path to save species-level data.
#' @param genus_dir_path The directory path to save genus-level data.
#' @return None. This function writes the filtered data into files at the specified
#'   paths.
#' @examples
#' \dontrun{
#' gbif_custom_retrieve("path/to/taxonomy.rds", "path/to/data", 
#'   "path/to/species", "path/to/genus")
#' }
#' @importFrom arrow open_dataset
#' @export
gbif_custom_retrieve <- function(taxonomy_file_path, data_file_path, species_dir_path, genus_dir_path) {
  # Read taxonomy data
  lotvs_backbone_taxonomy <- readRDS(taxonomy_file_path)
  local_df <- open_dataset(paste0(data_file_path, "/occurrence.parquet"),
                           factory_options = list(exclude_invalid_files = TRUE)
  )
  
  write_chunks(
    local_df, lotvs_backbone_taxonomy |> filter(rank == "SPECIES"),
    "SPECIES", species_dir_path, 100
  )
  write_chunks(
    local_df, lotvs_backbone_taxonomy |> filter(rank == "GENUS"),
    "GENUS", genus_dir_path, 20
  )
}


#' Write Dataset Chunks Based on Taxonomic Rank
#'
#' This function writes the dataset into separate files based on taxonomic rank 
#' (species or genus) and saves them in the specified directories. It splits 
#' the data into chunks for efficient processing and writing.
#'
#' @param local_df The dataset to be filtered and written. This is typically a 
#'   `DataFrame` or a `dataset` from the `arrow` package.
#' @param lotvs_backbone_taxonomy A data frame containing taxonomic information 
#'   used for filtering the dataset, which includes the `usageKey` for species 
#'   and genus columns.
#' @param rank A character string, either "SPECIES" or "GENUS", indicating the rank 
#'   for filtering the data.
#' @param dir_path The directory where the filtered data will be saved.
#' @param chunk_size The number of records per chunk to be written.
#' @return None. This function writes the data into files at the specified paths.
#' @keywords internal
#' @import tidyverse
#' @importFrom arrow write_dataset
#' @examples
#' \dontrun{
#' write_chunks(local_df, lotvs_backbone_taxonomy, "SPECIES", "path/to/species_dir", 100)
#' }
write_chunks <- function(local_df, lotvs_backbone_taxonomy, rank, dir_path, chunk_size) {
  dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
  
  if (rank == "SPECIES") {
    keys <- lotvs_backbone_taxonomy %>%
      pull(usageKey)
    column <- "specieskey"
  } else {
    keys <- lotvs_backbone_taxonomy %>%
      pull(genus)
    column <- "genus"
  }
  
  keys_chunks <- split(keys, ceiling(seq_along(keys) / chunk_size))
  
  walk2(
    keys_chunks,
    seq_along(keys_chunks),
    function(keys_chunk, idx) {
      message("Writing ", rank, " chunk ", idx, " of ", length(keys_chunks))
      local_df %>%
        filter(!!sym(column) %in% keys_chunk) %>%
        write_dataset(
          path = dir_path,
          format = "parquet",
          partitioning = column,
          existing_data_behavior = "overwrite"
        )
    }
  )
}

