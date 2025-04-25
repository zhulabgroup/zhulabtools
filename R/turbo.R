#' Create a Symbolic Link to UMich Turbo Storage
#'
#' This function generates a symbolic link within a project directory pointing to a specified location
#' on the University of Michigan Turbo Research Storage system. It determines the appropriate mount point
#' based on the operating system and creates the link accordingly. Importantly, the symbolic link must
#' reside within the current R project's directory. The link cannot be on Turbo because symbolic links
#' on Turbo differ across operating systems.
#'
#' @param project_symlink A character string defining the path, relative to the project root, where the symbolic link will be created.
#' This must be a path within the R project directory. It cannot be a path on Turbo.
#' @param turbo_target A character string specifying the path, relative to the Turbo mount point, where the symbolic link should point.
#' @param turbo_volume A character string representing the name of the Turbo volume. The default volume is 'seas-zhukai'.
#'
#' @return A logical value indicating whether the symbolic link was successfully created (\code{TRUE}) or not (\code{FALSE}).
#'   The function mainly operates via side effects (creating or managing symbolic links) and informs the user through messages.
#' @examples
#' \dontrun{
#' # Example to create a symbolic link named "data" pointing to "turbo-folder" on the Turbo storage
#' create_symlink_turbo("data", "turbo-folder")
#' }
#' @seealso \code{\link{file.symlink}}, \code{\link{unlink}}, \code{\link{Sys.info}}, \code{\link[R.utils]{createLink}}
#' @export
create_symlink_turbo <- function(project_symlink, turbo_target, turbo_volume = "seas-zhukai") {
  # Detect the operating system
  os_name <- Sys.info()[["sysname"]]

  # Determine the Turbo mount point based on the operating system
  turbo_mount_point <- switch(os_name,
    Darwin = file.path("/Volumes", turbo_volume), # macOS
    Linux = file.path("/nfs/turbo", turbo_volume), # Linux
    Windows = "Z:\\", # Windows (assuming the volume is mapped to Z:)
    stop("Unsupported operating system: ", os_name)
  )

  # Construct the target path and check if it exists
  target <- file.path(turbo_mount_point, turbo_target)
  if (!file.exists(target)) {
    stop("Target path does not exist: ", target)
  }

  # Construct the symbolic link path
  project_root <- here::here()
  symlink <- file.path(project_root, project_symlink)

  # Check if the symbolic link exists and is valid
  symlink_exists <- if (os_name == "Windows") {
    file.exists(symlink)
  } else {
    file.exists(symlink) && (Sys.readlink(symlink) == target)
  }

  # Avoid recreating a valid symlink to save time
  if (symlink_exists) {
    message("Valid symbolic link already exists: ", symlink, " -> ", target)
    return(TRUE)
  }

  # Check if the new symlink to create is within the project directory
  if (!startsWith(normalizePath(symlink, mustWork = FALSE), normalizePath(project_root))) {
    stop("The symlink path must be within the R project directory: ", project_root)
  }

  # Remove the existing symlink if it exists but is not valid
  if ((os_name == "Windows" && file.exists(symlink)) || (os_name != "Windows" && (file.exists(symlink) || !is.na(Sys.readlink(symlink))))) {
    message("Removing existing invalid symlink: ", symlink)
    unlink(symlink, recursive = TRUE)
  }

  # Create the new symbolic link based on the operating system
  success <- switch(os_name,
    Darwin = file.symlink(target, symlink), # macOS
    Linux = file.symlink(target, symlink), # Linux
    Windows = R.utils::createLink(symlink, target), # Windows
    stop("Unsupported operating system: ", os_name)
  )

  # Report success or failure
  if (!success) {
    warning("Failed to create symbolic link: ", symlink, " -> ", target)
    return(FALSE)
  } else {
    message("Symbolic link created: ", symlink, " -> ", target)
    return(TRUE)
  }
}
