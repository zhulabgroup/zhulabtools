#' Custom GBIF Data Download
#'
#' This function initiates the download of customized GBIF data. It loads the 
#' `lotvs_backbone` from the provided path, splits the taxon usage keys into chunks, 
#' calculates the total occurrence count for the taxa, and then submits the 
#' occurrence download request for those taxa.
#'
#' @param lotvs_backbone_path The path to the `lotvs_backbone` RDS file containing
#'   the usage keys.
#' @return None. This function primarily initiates the download request and prints
#'   the total occurrence count.
#' @examples
#' \dontrun{
#' gbif_custom_download("path/to/lotvs_backbone.rds")
#' }
#' @import tidyverse
#' @export
gbif_custom_download <- function(lotvs_backbone_path) {
  # Load lotvs_backbone from provided path
  lotvs_backbone <- readr::read_rds(lotvs_backbone_path)
  taxon_chunks <- split_into_chunks(lotvs_backbone$usageKey, 1000)
  
  total_occurrence_count <- get_total_occurrence_count(taxon_chunks)
  print(total_occurrence_count)
  
  submit_occ_download(lotvs_backbone$usageKey)
}

#' Split a Vector into Chunks
#'
#' This function splits a taxon vector into smaller chunks of a specified size.
#'
#' @param x A vector to be split into chunks.
#' @param chunk_size The size of each chunk.
#' @return A list of chunks, where each chunk is a subvector of the input vector.
#' @keywords internal
#' @examples
#' split_into_chunks(1:10, 3)
#' # Returns: list(1:3, 4:6, 7:9, 10)
split_into_chunks <- function(x, chunk_size) {
  split(x, ceiling(seq_along(x) / chunk_size))
}

#' Get Total Occurrence Count
#'
#' This function calculates the total number of occurrences for a list of taxon keys
#'
#' @param taxon_chunks A list of taxon key chunks to be processed.
#' @return The total occurrence count.
#' @keywords internal
#' @import tidyverse
#' @importFrom rgbif occ_count
#' @examples
#' taxon_chunks <- list(c("key1", "key2"), c("key3", "key4"))
#' get_total_occurrence_count(taxon_chunks)
#' # Returns: total occurrence count for the provided chunks
get_total_occurrence_count <- function(taxon_chunks) {
  total_occurrence_count <- 0
  for (chunk in taxon_chunks) {
    taxon_list <- stringr::str_c(chunk, collapse = ";")
    count <- occ_count(
      taxonKey = taxon_list,
      hasCoordinate = TRUE,
      hasGeospatialIssue = FALSE,
      occurrenceStatus = "PRESENT",
      basisOfRecord = "HUMAN_OBSERVATION"
    )
    total_occurrence_count <- total_occurrence_count + count
  }
  return(total_occurrence_count)
}

#' Submit Occurrence Data Download Request
#'
#' This function submits the request to download occurrence data from GBIF 
#' based on a specified taxon key. It filters the data based on certain criteria,
#' such as coordinate presence, geospatial issues, occurrence status, and record basis.
#'
#' @param lotvs_backbone_usage_key A character vector of taxon keys to download occurrence data.
#' @return A download object or request ID representing the submitted download.
#' @keywords internal
#' @importFrom rgbif occ_download
#' @examples
#' \dontrun{
#' submit_occ_download("some_taxon_key")
#' }
submit_occ_download <- function(lotvs_backbone_usage_key) {
  rgbif::occ_download(
    rgbif::pred_in("taxonKey", lotvs_backbone_usage_key),
    rgbif::pred("hasCoordinate", TRUE),
    rgbif::pred("hasGeospatialIssue", FALSE),
    rgbif::pred("occurrenceStatus", "PRESENT"),
    rgbif::pred("basisOfRecord", "HUMAN_OBSERVATION"),
    format = "SIMPLE_PARQUET"
  )
}