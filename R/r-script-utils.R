#' Concatenate R and Quarto Scripts in a Directory
#'
#' This function concatenates the contents of all `.R` and `.qmd` files in a specified directory,
#' printing each with its filename as a header and wrapping the code in the appropriate code fence (such as `r` or `qmd`).
#' Optionally, it writes all combined text to an output file (e.g., Markdown or text file).
#'
#' @param dir Character. Directory to search for scripts. Default is current directory (`"."`).
#' @param pattern Regular expression for file types to include. Default: `"\\.(R|qmd)$"` (case-insensitive).
#' @param output_file Character or `NULL`. If a filename is provided, the combined script text is written to that file.
#'   If `NULL` (default), all content is printed to the console.
#' @param charset Character. Text encoding to use when reading scripts. Default is `"UTF-8"`.
#'
#' @return Invisibly returns a character vector of the combined, formatted script text.
#' @examples
#' \dontrun{
#' # Print all R and qmd files in current directory to console
#' concat_scripts_in_dir()
#'
#' # Write all scripts from "analysis" folder to an output markdown file
#' concat_scripts_in_dir(dir = "analysis", output_file = "all_scripts.md")
#' }
#' @importFrom fs dir_ls path_file
#' @importFrom purrr map_chr
#' @importFrom readr read_lines write_lines locale
#' @importFrom tools file_ext
#' @export
concat_scripts_in_dir <- function(dir = ".",
                                  pattern = "\\.(R|qmd)$",
                                  output_file = NULL,
                                  charset = "UTF-8") {
  # Check required packages
  for (pkg in c("fs", "readr", "purrr")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop("Package '", pkg, "' is required. Please install it.", call. = FALSE)
    }
  }

  # List matching files (case-insensitive)
  files <- fs::dir_ls(path = dir, regexp = pattern, recurse = FALSE, type = "file", ignore.case = TRUE)

  if (length(files) == 0) {
    message("No '.R' or '.qmd' files found in directory: ", dir)
    return(invisible(character()))
  }

  cat_file_with_header <- function(file) {
    fname <- fs::path_file(file)
    ext <- tolower(tools::file_ext(fname))
    fence <- switch(ext,
      "r" = "```r",
      "qmd" = "```qmd",
      "```"
    )
    content <- tryCatch(
      readr::read_lines(file, locale = readr::locale(encoding = charset)),
      error = function(e) {
        warning("Failed to read ", fname, ": ", conditionMessage(e))
        return(character(0))
      }
    )
    paste0(
      "\n# [", fname, "]\n",
      fence, "\n",
      paste(content, collapse = "\n"),
      "\n```\n"
    )
  }

  all_text <- purrr::map_chr(files, cat_file_with_header)

  if (is.null(output_file)) {
    cat(all_text, sep = "\n")
  } else {
    readr::write_lines(all_text, output_file)
    message("Wrote concatenated scripts to: ", output_file)
  }

  invisible(all_text)
}
