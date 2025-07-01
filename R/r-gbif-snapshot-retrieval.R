#' Retrieve GBIF Occurrences
#'
#' This function retrieves and processes GBIF occurrences from a snapshot located at a given path. 
#' It filters the data based on taxonomy records (class and order), processes the records for each species 
#' and genus, and saves the resulting data as `.rds` files in the specified save directory.
#'
#' @param save_path The directory where the filtered species and genus data will be saved.
#' @param gbif_snapshot_path The path to the GBIF snapshot, typically in Parquet format.
#' @param taxonomy_list A data frame containing taxonomy information, including classification and rank information. 
#'   The file must include the rank information (e.g., "species" or "genus").
#'   For species taxa, the `taxonomy_list` must include the GBIF `usageKey` for each species.
#'   For genus taxa, the `taxonomy_list` must include the `genus` name for each genus.
#' @return None. This function saves the filtered and processed occurrence data as `.rds` files in the specified directory.
#' @examples
#' \dontrun{
#' gbif_snapshot_retrieve("path/to/save", "path/to/gbif_snapshot", taxonomy_list)
#' }
#' @export
gbif_snapshot_retrieve <- function(save_path, gbif_snapshot_path, taxonomy_list) {
  dir.create(save_path, recursive = TRUE, showWarnings = FALSE)
  
  class_order_list <- taxonomy_list |>
    distinct(class, order)
  
  for (i in seq_len(nrow(class_order_list))) {
    class_val <- class_order_list$class[i]
    order_val <- class_order_list$order[i]
    parquet_path <- file.path(gbif_snapshot_path, paste0("class=", class_val), paste0("order=", order_val))
    taxonomy_record <- taxonomy_list |>
      filter(class == class_val, order == order_val)
    process_taxonomy_record(taxonomy_record, parquet_path, save_path)
  }
}



#' Process Taxonomy Record
#'
#' This function processes the taxonomy records for a given class and order, retrieves the corresponding GBIF 
#' occurrence data, filters the records based on species and genus, and saves the results as `.rds` files.
#'
#' @param taxonomy_record A subset of the taxonomy list that contains information about a specific class and order.
#' @param parquet_path The path to the GBIF snapshot data (in Parquet format) for the specific class and order.
#' @param save_path The directory where the filtered species and genus data will be saved.
#' @return None. This function saves species and genus occurrence data as `.rds` files in the specified directory.
#' @keywords internal
#' @import tidyverse
#' @importFrom cli cli_text cli_alert_success
#' @importFrom arrow open_dataset
process_taxonomy_record <- function(taxonomy_record, parquet_path, save_path) {
  cli_text("Reading GBIF parquet: {.path {parquet_path}}")
  cli_text("No. of taxonomy records: {nrow(taxonomy_record)}")
  
  species_keys <- taxonomy_record |>
    filter(rank == "SPECIES") |>
    pull(usageKey) |>
    unique()
  genus_list <- taxonomy_record |>
    filter(rank == "GENUS") |>
    pull(genus) |>
    unique()
  
  cli_text("Number of species keys: {length(species_keys)}")
  cli_text("Number of genus names: {length(genus_list)}")
  
  all_occ <- open_dataset(parquet_path) |>
    filter(specieskey %in% species_keys | genus %in% genus_list) |>
    filter(!is.na(decimallatitude) & !is.na(decimallongitude)) |>
    filter(occurrencestatus == "PRESENT") |>
    select(
      species, genus, family, specieskey, decimallongitude, decimallatitude,
      countrycode, taxonkey, basisofrecord, occurrencestatus,
      lastinterpreted, issue, year, coordinateprecision, coordinateuncertaintyinmeters
    ) |>
    collect()
  
  for (key in species_keys) {
    species_save_path <- file.path(save_path, paste0("specieskey_", key, ".rds"))
    
    if (file.exists(species_save_path)) {
      cat(paste0("File already exists: ", species_save_path, "\n"))
      next
    }
    
    species_occ <- all_occ |> filter(specieskey == key)
    saveRDS(species_occ, species_save_path, compress = TRUE)
    cli_text("Saved species key: {.val {key}} with {nrow(species_occ)} records")
  }
  
  for (genus_name in genus_list) {
    genus_save_path <- file.path(save_path, paste0("genus_", genus_name, ".rds"))
    
    if (file.exists(genus_save_path)) {
      cat(paste0("File already exists: ", genus_save_path, "\n"))
      next
    }
    
    genus_occ <- all_occ |> filter(genus == genus_name)
    saveRDS(genus_occ, genus_save_path, compress = TRUE)
    cli_text("Saved genus: {.val {genus_name}} with {nrow(genus_occ)} records")
  }
  
  cli_alert_success("All taxonomy records processed.")
}
