#' Concatenate R, R Markdown, and Quarto Scripts
#'
#' Concatenate the contents of all `.R`, `.Rmd`, or `.qmd` files either by searching a directory (recursively by default)
#' or from a specified list of files. Each script is preceded by a header with its relative filename (from the current working directory)
#' and wrapped in an appropriate code fence for Markdown documents.
#'
#' By default, output is copied to the system clipboard. If `clipboard = TRUE`, no file or console output is produced.
#' If `clipboard = FALSE` and `outfile` is supplied, results are written to a file.
#' Otherwise, results are printed to the console.
#'
#' @param dir Character. Directory in which to search for files. Ignored if \code{files} is provided. Defaults to current working directory.
#' @param files Optional character vector of file paths to concatenate. If \code{NULL} (default), the function will search \code{dir} for files matching \code{pattern}.
#' @param pattern Character. Regular expression specifying the file types to include. By default, matches all files ending with `.R`, `.Rmd`, or `.qmd` (case-insensitive).
#' @param recursive Logical. Should the file search be recursive in \code{dir}? Default is \code{TRUE}.
#' @param clipboard Logical. If \code{TRUE} (default), concatenated output is copied to the system clipboard (macOS/Windows/Linux supported) and no file or console output is produced.
#' @param outfile Optional character string specifying a file to which results should be written. Only used if \code{clipboard = FALSE}. If \code{NULL}, output is printed to the console.
#' @param charset Character. The text encoding to use when reading files. Default is \code{"UTF-8"}.
#' @return (Invisibly) a character vector containing the concatenated, annotated script text (invisibly).
#' @examples
#' \dontrun{
#' concat_code()
#' concat_code(dir = "scripts", recursive = FALSE)
#' myfiles <- list.files("R", pattern = "\\.(R|Rmd|qmd)$", full.names = TRUE)
#' concat_code(files = myfiles)
#' concat_code(dir = "vignettes", outfile = "all_code.md", clipboard = FALSE)
#' }
#' @export
concat_code <- function(
  dir = ".",
  files = NULL,
  pattern = "\\.(R|Rmd|qmd)$",
  recursive = TRUE,
  clipboard = TRUE,
  outfile = NULL,
  charset = "UTF-8"
) {
  # If the user hasn't provided specific files, find all matching files in the directory.
  if (is.null(files)) {
    files <- list.files(
      path = dir,
      pattern = pattern,
      full.names = TRUE,
      ignore.case = TRUE,
      recursive = recursive
    )
  }

  # Graceful exit if no matching files were found.
  if (length(files) == 0) {
    message("No matching script files found to concatenate.")
    return(invisible(character()))
  }

  # Read and concatenate contents, annotate each file for markdown output.
  all_text <- vapply(files, process_file, charset = charset, FUN.VALUE = character(1), USE.NAMES = FALSE)
  txt <- paste(all_text, collapse = "\n")

  # Prefer clipboard output if requested, then file, then console.
  if (clipboard) {
    copy_to_clipboard(txt)
    message("Output copied to clipboard!")
    return(invisible(all_text))
  } else if (!is.null(outfile)) {
    writeLines(all_text, outfile, useBytes = TRUE)
    message("Wrote concatenated scripts to: ", outfile)
    return(invisible(all_text))
  } else {
    cat(all_text, sep = "\n")
    return(invisible(all_text))
  }
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
