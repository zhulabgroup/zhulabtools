#' Create Project Subfolders
#'
#' This function sets up specified subfolders within a project's root directory.
#'
#' @param project_path A character string specifying the path to the project root directory.
#'   The default is the current working directory (".").
#' @param subfolders A character vector indicating the names of subfolders to be created within
#'   the project directory. The default subfolders are \code{c("R", "vignettes")}.
#'
#' @return A logical value (\code{TRUE}) indicating if the subfolder creation was successful.
#' @examples
#' \dontrun{
#' # Create default subfolders in the current directory
#' create_subfolders()
#'
#' # Create specified subfolders in a specified directory
#' create_subfolders("/path/to/your/project", c("R", "vignettes"))
#' }
#' @export
create_subfolders <- function(project_path = ".", subfolders = c("R", "vignettes")) {
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
  return(TRUE)
}

#' Create .gitignore File
#'
#' This function creates a .gitignore file in the project's root directory based on a template.
#'
#' @param project_path A character string specifying the path to the project root directory.
#'   The default is the current working directory (".").
#' @param overwrite_gitignore A logical value indicating whether to overwrite an existing
#'   .gitignore file in the project directory. Defaults to \code{FALSE}.
#'
#' @return A logical value (\code{TRUE}) indicating if the .gitignore file creation was successful.
#' @examples
#' \dontrun{
#' # Create or overwrite .gitignore in the current directory
#' create_gitignore(overwrite_gitignore = TRUE)
#'
#' # Create .gitignore in a specified directory without overwriting
#' create_gitignore("/path/to/your/project")
#' }
#' @export
create_gitignore <- function(project_path = ".", overwrite_gitignore = FALSE) {
  # Define path to the template .gitignore file
  template_gitignore_path <- system.file("templates/gitignore.txt", package = "zhulabtools")
  
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

#' Create Quarto YAML File
#'
#' This function creates a _quarto.yml file in the project's root directory based on a template.
#'
#' @param project_path A character string specifying the path to the project root directory.
#'   The default is the current working directory (".").
#' @param overwrite_quarto A logical value indicating whether to overwrite an existing
#'   _quarto.yml file in the project directory. Defaults to \code{FALSE}.
#'
#' @return A logical value (\code{TRUE}) indicating if the _quarto.yml file creation was successful.
#' @examples
#' \dontrun{
#' # Create or overwrite _quarto.yml in the current directory
#' create_quarto_yaml(overwrite_quarto = TRUE)
#'
#' # Create _quarto.yml in a specified directory without overwriting
#' create_quarto_yaml("/path/to/your/project")
#' }
#' @export
create_quarto_yaml <- function(project_path = ".", overwrite_quarto = FALSE) {
  # Define path to the template _quarto.yml file
  template_quarto_path <- system.file("templates/quarto-yaml.txt", package = "zhulabtools")
  
  if (template_quarto_path == "") {
    stop("The _quarto.yml template could not be found in the package.")
  }
  
  # Read the template file content
  quarto_content <- readLines(template_quarto_path)
  
  # Path to _quarto.yml file
  quarto_path <- file.path(project_path, "_quarto.yml")
  
  # Check if _quarto.yml file already exists and whether to overwrite it
  if (!file.exists(quarto_path) || overwrite_quarto) {
    # Write the _quarto.yml template content to the project root
    writeLines(quarto_content, con = quarto_path)
    message("Created _quarto.yml file at: ", quarto_path)
  } else {
    message("_quarto.yml file already exists at: ", quarto_path)
  }
  
  return(TRUE)
}
