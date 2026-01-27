#' Concatenate R, R Markdown, and Quarto Scripts
#'
#' Concatenate the contents of all `.R`, `.Rmd`, or `.qmd` files, either from a specified list of files
#' or by searching a directory. Each script is preceded by a header with its relative filename (from the current working directory)
#' and wrapped in an appropriate code fence for use in Markdown documents. The result can be printed to the console
#' or written to an output file.
#'
#' @param files Optional character vector of file paths to concatenate. If `NULL` (default), the function
#'   will search \code{dir} for files matching \code{pattern}.
#' @param dir Character. Directory in which to search for files. Used only if \code{files} is \code{NULL}.
#'   Defaults to the current working directory.
#' @param pattern Character. Regular expression specifying the file types to include. By default,
#'   matches all files ending with `.R`, `.Rmd`, or `.qmd` (case-insensitive).
#' @param output_file Optional character string specifying a file to which results should be written.
#'   If \code{NULL} (default), output is printed to the console.
#' @param charset Character. The text encoding to use when reading files. Default is `"UTF-8"`.
#' @param recursive Logical. Should the file search be recursive? Default is `TRUE`.
#' @return (Invisibly) a character vector containing the concatenated, annotated script text.
#' @examples
#' \dontrun{
#' # Concatenate all .R, .Rmd, and .qmd files recursively in the current directory and print result
#' concat_scripts()
#'
#' # Specify a directory, non-recursively
#' concat_scripts(dir = "scripts", recursive = FALSE)
#'
#' # Pipe in a custom file list
#' myfiles <- list.files("R", pattern = "\\.(R|Rmd|qmd)$", ignore.case = TRUE, full.names = TRUE)
#' concat_scripts(files = myfiles)
#'
#' # Write concatenation to a markdown file
#' concat_scripts(dir = "vignettes", output_file = "all_code.md")
#' }
#' @export
concat_scripts <- function(
  files = NULL,
  dir = ".",
  pattern = "\\.(R|Rmd|qmd)$",
  output_file = NULL,
  charset = "UTF-8",
  recursive = TRUE,
  clipboard = TRUE
) {
  # Step 1: Get list of files if files not provided
  if (is.null(files)) {
    files <- list.files(
      path = dir,
      pattern = pattern,
      full.names = TRUE,
      ignore.case = TRUE,
      recursive = recursive
    )
  }

  # Step 2: If no files found, exit gracefully
  if (length(files) == 0) {
    message("No matching script files found to concatenate.")
    return(invisible(character()))
  }

  # Step 4: Process all files and collect output
  all_text <- vapply(files, process_file, charset = charset, FUN.VALUE = character(1), USE.NAMES = FALSE)
  
  # Step 5: Output the result to console or file
  if (is.null(output_file)) {
    cat(all_text, sep = "\n")
  } else {
    writeLines(all_text, output_file, useBytes = TRUE)
    message("Wrote concatenated scripts to: ", output_file)
  }

  # Step 6: Copy to clipboard if requested
  if (clipboard) {
    txt <- paste(all_text, collapse = "\n")
    copy_to_clipboard(txt)
    message("Output copied to clipboard!")
  }

  invisible(all_text)
}

# Copy to clipboard
#' @noRd
copy_to_clipboard <- function(txt) {
  sysname <- Sys.info()[["sysname"]]
  if (sysname == "Windows") {
    writeClipboard(txt)
    return(invisible(TRUE))
  } else if (sysname == "Darwin") {
    con <- pipe("pbcopy", "w")
    writeLines(txt, con)
    close(con)
    return(invisible(TRUE))
  } else {
    if (nzchar(Sys.which("xclip"))) {
      con <- pipe("xclip -selection clipboard", "w")
      writeLines(txt, con)
      close(con)
      return(invisible(TRUE))
    } else if (nzchar(Sys.which("xsel"))) {
      con <- pipe("xsel --clipboard --input", "w")
      writeLines(txt, con)
      close(con)
      return(invisible(TRUE))
    } else {
      warning("No clipboard utility (xclip/xsel) found. Text not copied.")
      return(invisible(FALSE))
    }
  }
}

# Extracts and lowercases the file extension
#' @noRd
get_file_ext <- function(filename) {
  fname <- basename(filename)
  ext <- sub(".*\\.", "", fname)
  ifelse(grepl("\\.", fname), tolower(ext), "")
}

# Get relative path from current working directory
#' @noRd
get_rel_path <- function(path) {
  wd <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  abs <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (startsWith(abs, paste0(wd, "/"))) {
    substring(abs, nchar(wd) + 2)
  } else {
    abs # Use absolute path if file is not under working directory
  }
}

# Process a single file and return annotated text
#' @noRd
process_file <- function(file, charset) {
  fname <- get_rel_path(file)
  ext <- get_file_ext(fname)
  fence <- switch(ext,
                  "r" = "```r",
                  "rmd" = "```{r}",
                  "qmd" = "```qmd",
                  "```"
  )
  content <- tryCatch(
    readLines(file, encoding = charset, warn = FALSE),
    error = function(e) {
      warning("Failed to read ", fname, ": ", conditionMessage(e))
      character(0)
    }
  )
  paste0(
    "\n# [", fname, "]\n",
    fence, "\n",
    paste(content, collapse = "\n"),
    "\n```\n"
  )
}
