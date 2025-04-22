#' Create Symbolic Link to UMich Turbo
#'
#' Create a symbolic link in the project directory to UMich Turbo Research Storage.
#'
#' @param project_symlink Path relative to the project root where the symbolic link will be created.
#' @param turbo_target Path relative to the Turbo mount point.
#' @param turbo_volume Name of the Turbo volume, default is 'seas-zhukai'.
#'
#' @return Logical value indicating if the symbolic link was successfully created.
#' @examples
#' \dontrun{
#' create_symlink_turbo("data", "turbo-folder")
#' }
#' @export
create_symlink_turbo <- function(project_symlink, turbo_target, turbo_volume = "seas-zhukai") {
  # Detect operating system
  os_name <- Sys.info()[["sysname"]]

  # Determine the mount point based on OS
  turbo_mount_point <- switch(os_name,
    Darwin = file.path("/Volumes", turbo_volume), # macOS
    Linux = file.path("/nfs/turbo", turbo_volume), # Linux
    Windows = "Z:\\", # Windows (assuming the volume is mapped to Z:)
    stop("Unsupported operating system: ", os_name)
  )

  # Construct target and symlink paths
  target <- file.path(turbo_mount_point, turbo_target)
  project_root <- here::here()
  symlink <- file.path(project_root, project_symlink)

  # Check if symlink exists and is valid
  symlink_exists <- if (os_name == "Windows") {
    file.exists(symlink)
  } else {
    file.exists(symlink) && (Sys.readlink(symlink) == target)
  }

  # If symlink is valid, avoid recreating it to save time
  if (symlink_exists) {
    message("Valid symbolic link already exists: ", symlink, " -> ", target)
    return(TRUE)
  }

  # Remove existing symlink if it exists but is not valid
  if ((os_name == "Windows" && file.exists(symlink)) || (os_name != "Windows" && (file.exists(symlink) || !is.na(Sys.readlink(symlink))))) {
    message("Removing existing symlink: ", symlink)
    unlink(symlink, recursive = TRUE)
  }

  # Create symbolic link based on OS
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
