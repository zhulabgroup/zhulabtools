#' Check and Install Missing Packages
#'
#' This function checks if a series of packages are installed,
#' and installs those that are not installed yet. It also prints
#' messages to indicate which packages are already installed,
#' and which are being installed.
#'
#' @param packages A character vector of package names to check and install if necessary.
#' @return NULL. The function is called for its side effect of installing missing packages.
#' @examples
#' \dontrun{
#' check_install_packages(c("dplyr", "ggplot2"))
#' }
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
#' This function loads a series of packages into the R session.
#' It also prints messages to indicate which packages are being loaded.
#'
#' @param packages A character vector of package names to load.
#' @return NULL. The function is called for its side effect of loading packages.
#' @examples
#' \dontrun{
#' load_packages(c("dplyr", "ggplot2"))
#' }
#' @export
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
#' This function updates a specified series of packages to the latest version
#' on CRAN, including their dependencies.
#'
#' @param packages A character vector of package names to update.
#' @return NULL. The function is called for its side effect of updating packages.
#' @examples
#' \dontrun{
#' update_packages(c("dplyr", "ggplot2"))
#' }
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
