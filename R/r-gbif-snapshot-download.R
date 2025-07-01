#' Set Up S3 Bucket Connection
#'
#' This function sets up a connection to an S3 bucket, using either a proxy or direct connection, depending on the provided parameters.
#'
#' @param bucket_name The name of the S3 bucket to connect to.
#' @param endpoint The endpoint URL of the S3 service.
#' @param region The AWS region where the bucket is located.
#' @param proxy Optional. A list of proxy options to use for the connection. If not provided, a direct connection is used.
#' @return An S3 bucket connection object.
#' @examples
#' setup_s3_bucket(bucket_name = "gbif-open-data-us-east-1",
#' endpoint = "https://s3.us-east-1.amazonaws.com",
#' region = "us-east-1",
#' proxy = "http://proxy1.arc-ts.umich.edu:3128" # For using Slurm on Greatlakes)
#' @export
#' @importFrom arrow s3_bucket
setup_s3_bucket <- function(bucket_name, endpoint, region, proxy = NULL) {
  if (!is.null(proxy)) {
    s3_bucket(
      bucket = bucket_name,
      endpoint_override = endpoint,
      region = region,
      proxy_options = proxy
    )
  } else {
    s3_bucket(
      bucket = bucket_name,
      endpoint_override = endpoint,
      region = region
    )
  }
}


#' Download and Filter GBIF Snapshot with Filtering and Partitioning
#'
#' This function downloads a GBIF snapshot, filters it based on the specified biological classification levels and values,
#' and saves the filtered data into the specified local directory in Parquet format with flexible partitioning.
#'
#' @param bucket_fs The filesystem connection for the S3 bucket, used to access the snapshot.
#' @param snapshot_path The path to the GBIF snapshot on the S3 bucket.
#' @param local_save_dir The local directory to save the filtered snapshot.
#' @param filter_level A character vector of classification levels to filter the data by (e.g., "kingdom", "phylum").
#'   Default is `c("kingdom", "phylum")`.
#' @param filter_value A character vector of values for the classification levels (e.g., "Plantae", "Tracheophyta").
#'   Default is `c("Plantae", "Tracheophyta")`.
#' @param partition_columns A character vector specifying which columns to use for partitioning the data.
#'   For example, `c("class", "order")`.
#' @return None. This function writes the filtered data into files at the specified local directory.
#' @examples
#' gbif_snapshot_download(bucket_fs, "gbif_snapshot_url", "local_dir", 
#'   filter_level = c("kingdom", "phylum"), filter_value = c("Plantae", "Tracheophyta"), partition_columns = c("class", "order"))
#' @export
#' @importFrom arrow open_dataset write_dataset
#' @importFrom dplyr filter
gbif_snapshot_download <- function(
    bucket_fs,
    snapshot_path,
    local_save_dir,
    filter_level = c("kingdom", "phylum"),  # Default filter levels
    filter_value = c("Plantae", "Tracheophyta"),  # Default filter values
    partition_columns = c("class", "order")) {  # Default partition columns
  
  if (!dir.exists(local_save_dir)) {
    dir.create(local_save_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # Create dynamic filtering expression based on the filter_level and filter_value parameters
  if (length(filter_level) != length(filter_value)) {
    stop("The length of filter_level and filter_value must be the same.")
  }
  filter_expr <- NULL
  for (i in seq_along(filter_level)) {
    # Create the filter expression dynamically
    current_filter <- expr(!!sym(filter_level[i]) == !!filter_value[i])
    if (is.null(filter_expr)) {
      filter_expr <- current_filter
    } else {
      filter_expr <- expr(!!filter_expr & !!current_filter)
    }
  }
  
  # Open the dataset, apply the filter, and write the dataset with flexible partitioning
  filtered_data <- open_dataset(snapshot_path) %>%
    filter(!!filter_expr)
  
  # Write the filtered data to the specified directory with flexible partitioning
  filtered_data %>%
    write_dataset(local_save_dir, format = "parquet", partitioning = partition_columns)
}
