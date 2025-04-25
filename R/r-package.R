#' Check and Install Missing Packages
#'
#' This function checks whether each package in a specified list is installed.
#' If any packages are missing, they are automatically installed. The function
#' also provides messages to indicate the status of each package, either
#' confirming that it's already installed or notifying the user of the
#' installation progress.
#'
#' @param packages A character vector of package names that need to be checked
#'   and possibly installed.
#' @return NULL. This function primarily generates side effects (installing
#'   missing packages) and outputs messages to the console.
#' @examples
#' \dontrun{
#' check_install_packages(c("dplyr", "ggplot2"))
#' }
#' @seealso \code{\link{install.packages}}, \code{\link{installed.packages}}
#' @importFrom utils installed.packages install.packages
#' @export
check_install_packages <- function(packages) {
  # Helper function to check if a package is installed
  is_installed <- function(pkg) {
    pkg %in% rownames(installed.packages())
  }

  # Install packages that are not installed and print status messages
  for (pkg in packages) {
    if (is_installed(pkg)) {
      message(sprintf("Package '%s' is already installed.", pkg))
    } else {
      message(sprintf("Package '%s' is not installed. Installing now...", pkg))
      install.packages(pkg)
      message(sprintf("Package '%s' has been installed.", pkg))
    }
  }
}

#' Load Specified Packages
#'
#' This function loads a list of specified packages into the current R session.
#' For each package, it prints messages to inform the user about the loading
#' process, indicating whether loading is successful.
#'
#' @param packages A character vector of package names that need to be loaded
#'   into the session.
#' @return NULL. This function is used for its side effects of loading packages
#'   and providing console messages.
#' @examples
#' \dontrun{
#' load_packages(c("dplyr", "ggplot2"))
#' }
#' @export
#' @seealso \code{\link{library}}
load_packages <- function(packages) {
  # Load each package and print status messages
  for (pkg in packages) {
    message(sprintf("Loading package '%s'...", pkg))
    library(pkg, character.only = TRUE)
    message(sprintf("Package '%s' has been loaded.", pkg))
  }
}

#' Update Specified Packages
#'
#' This function updates specified packages to their latest available versions
#' on CRAN, along with their dependencies. It reports on the progress of each
#' update to help users track the changes.
#'
#' @param packages A character vector of package names that should be updated.
#' @return NULL. The function's primary role is to create side effects by
#'   updating packages and notifying users about the process via messages.
#' @examples
#' \dontrun{
#' update_packages(c("dplyr", "ggplot2"))
#' }
#' @seealso \code{\link{update.packages}}
#' @importFrom utils update.packages
#' @export
update_packages <- function(packages) {
  # Update each specified package including its dependencies
  for (pkg in packages) {
    message(sprintf("Updating package '%s' and its dependencies...", pkg))
    update.packages(
      lib.loc = .libPaths(),
      oldPkgs = pkg,
      ask = FALSE,
      dependencies = TRUE
    )
    message(sprintf("Package '%s' has been updated.", pkg))
  }
}
