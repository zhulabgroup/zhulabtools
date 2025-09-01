# zhulabtools: Tools for Zhu Lab at UMich

This repository contains a collection of R tools for managing projects, files, and data workflows in the Zhu Lab at the University of Michigan.
The package also includes several shell scripts to assist with common computing tasks on Turbo and Data Den.

## Installation

To install the latest version of the package from GitHub, use the following steps:

1. Open RStudio or your preferred R environment.
2. Install `devtools` if you don't have it yet:
    ```r
    install.packages("devtools")
    ```
3. Install **zhulabtools**:
    ```r
    devtools::install_github("zhulabgroup/zhulabtools")
    ```

## R Functions

The package provides a variety of R functions to streamline common project, data, and workflow tasks in the Zhu Lab environment. These functions cover areas such as project setup, package management, file organization, workflow automation, and more.

To explore the full set of available functions and their documentation, open R and run:

```r
help(package = "zhulabtools")
```

This will display all functions included in the package, with links to their individual help files for detailed usage instructions and examples.

## Shell Scripts

Reusable shell scripts are included in the package and can be found in the `inst/scripts/` directory of the installed package. These scripts support data archiving, batch file transfers, and automated workflows on the Zhu Lab’s computing systems.

To find the full path to a script:

```r
system.file("scripts/archivetar_scratch.sh", package = "zhulabtools")
```

To view the script directly in R:

```r
file.show(system.file("scripts/archivetar_scratch.sh", package = "zhulabtools"))
```

You can also use your favorite text editor or terminal to open the file using the displayed path.

To use a script:
- Copy it from the path above to your desired location, if needed.
- Make it executable with `chmod +x`.
- Follow the usage instructions found within each script.
