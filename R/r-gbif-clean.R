#' Clean Occurrence Files
#'
#' This function processes all `.rds` files in a specified directory, applies the cleaning function to each file,
#' and saves the cleaned data into an output directory. The cleaning process includes basic filtering and removing
#' problematic coordinates.
#'
#' @param input_dir The directory containing the `.rds` files with the occurrence data.
#' @param output_dir The directory where the cleaned occurrence files will be saved.
#' @return None. This function saves the cleaned occurrence data as `.rds` files in the specified output directory.
#' @examples
#' \dontrun{
#' clean_occ_files("path/to/input", "path/to/output")
#' }
#' @seealso \code{\link[CoordinateCleaner]{clean_coordinates}}
#' @export
clean_occ_files <- function(input_dir, output_dir) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  rds_files <- list.files(input_dir, pattern = "\\.rds$", full.names = TRUE)
  for (file in rds_files) {
    message("Processing: ", basename(file))
    data <- readRDS(file)
    cleaned_data <- clean_occ(data)
    output_path <- file.path(output_dir, basename(file))
    saveRDS(cleaned_data, output_path)
  }
}

#' Clean Occurrence Data
#'
#' This function applies basic filters and cleans coordinates of the occurrence data. It filters for "HUMAN_OBSERVATION"
#' and ensures that the coordinate uncertainty is less than or equal to 10,000 meters. It also applies various cleaning
#' tests to remove problematic coordinates (e.g., duplicates, zeros, etc.).
#'
#' @param occ_data A data frame containing the occurrence data to be cleaned. It must include columns such as 
#'   `basisofrecord`, `coordinateuncertaintyinmeters`, `decimallongitude`, `decimallatitude`, and `countrycode`.
#' @return A cleaned data frame with the same columns as the input, but with filtered and cleaned coordinates.
#' @keywords internal
#' @importFrom dplyr filter
#' @importFrom CoordinateCleaner clean_coordinates
#' @importFrom cli cli_alert_danger
clean_occ <- function(occ_data) {
  # basic filter
  occ_data <- occ_data |>
    filter(basisofrecord == "HUMAN_OBSERVATION") |>
    filter(is.na(coordinateuncertaintyinmeters) | coordinateuncertaintyinmeters <= 10000)
  
  if (nrow(occ_data) == 0) {
    cli_alert_danger("No records after filtering.")
    return(NULL)
  }
  
  # clean coordinates
  flags <- clean_coordinates(
    x = occ_data,
    lon = "decimallongitude",
    lat = "decimallatitude",
    countries = "countrycode",
    species = "species",
    tests = c("capitals", "centroids", "duplicates", "equal", "gbif", "institutions", "seas", "zeros")
  )
  
  occ_data_cleaned <- occ_data[flags$.summary, ]
  return(occ_data_cleaned)
}


