#' Initialize an R Project Structure
#'
#' This function sets up a standardized file structure for an R project within a specified directory.
#' It creates specified subfolders and a .gitignore file to manage unwanted files in version control.
#'
#' @param project_path A character string specifying the path to the project root directory.
#'   The default is the current working directory (".").
#' @param subfolders A character vector indicating the names of subfolders to be created within
#'   the project directory. The default subfolders are \code{c("R", "tests", "vignettes")}.
#' @param overwrite_gitignore A logical value indicating whether to overwrite an existing
#'   .gitignore file in the project directory. Defaults to \code{FALSE}.
#'
#' @return A logical value (\code{TRUE}) indicating if the initialization was successful.
#'   The function is primarily used for its side-effect of creating folders and a .gitignore file.
#' @examples
#' \dontrun{
#' # Initialize project folders and .gitignore in the current directory
#' initialize_project()
#'
#' # Initialize project folders and .gitignore in a specified directory
#' initialize_project("/path/to/your/project")
#'
#' # Initialize project folders with custom subfolders and overwrite existing .gitignore file
#' initialize_project(
#'   project_path = "/path/to/your/project",
#'   subfolders = c("R", "data", "docs"),
#'   overwrite_gitignore = TRUE
#' )
#' }
#' @seealso \code{\link{dir.create}}, \code{\link{file.path}}, \code{\link{writeLines}}
#' @export
initialize_project <- function(project_path = ".", subfolders = c("R", "tests", "vignettes"), overwrite_gitignore = FALSE) {
  # Create the subfolders if they do not exist
  for (folder in subfolders) {
    folder_path <- file.path(project_path, folder)
    if (!dir.exists(folder_path)) {
      dir.create(folder_path, recursive = TRUE)
      message("Created folder: ", folder_path)
    } else {
      message("Folder already exists: ", folder_path)
    }
  }

  # Define path to the template .gitignore file
  template_gitignore_path <- system.file("templates/gitignore_template.txt", package = "zhulabtools")

  if (template_gitignore_path == "") {
    stop("The .gitignore template could not be found in the package.")
  }

  # Read the template file content
  gitignore_content <- readLines(template_gitignore_path)

  # Path to .gitignore file
  gitignore_path <- file.path(project_path, ".gitignore")

  # Check if .gitignore file already exists and whether to overwrite it
  if (!file.exists(gitignore_path) || overwrite_gitignore) {
    # Write the .gitignore template content to the project root
    writeLines(gitignore_content, con = gitignore_path)
    message("Created .gitignore file at: ", gitignore_path)
  } else {
    message(".gitignore file already exists at: ", gitignore_path)
  }

  return(TRUE)
}
