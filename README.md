# zhulabtools: Tools for Zhu Lab at UMich

This repository contains R tools for managing projects, files, and data workflows in the Zhu Lab at the University of Michigan.  
User guides and workflow documentation are provided as R Markdown vignettes.

## Installation

To install the latest version of the package from GitHub, follow these steps:

1. Open RStudio or your preferred R environment.
2. Install the `devtools` package if you haven't already:
    ```r
    install.packages("devtools")
    ```

3. Install `zhulabtools` (choose one option):

   Standard installation (quickest, without vignettes):
    ```r
    devtools::install_github("zhulabgroup/zhulabtools")
    ```

   Installation including all vignettes and documentation:
    ```r
    devtools::install_github("zhulabgroup/zhulabtools", build_vignettes = TRUE)
    ```

   If you receive a message asking to use `force = TRUE`, it means the package is already installed. To overwrite the previous installation, run:
    ```r
    devtools::install_github("zhulabgroup/zhulabtools", build_vignettes = TRUE, force = TRUE)
    ```

Tip: Building vignettes ensures you have access to workflow guides and full documentation inside R. This may take a bit longer but is recommended if you plan to use the package’s tutorials and step-by-step guides.

## R Functions

The package provides a variety of R functions to streamline common project, data, and workflow tasks in the Zhu Lab environment. Functions cover project setup, package management, file organization, workflow automation, and more.

To explore the full set of available functions and their documentation, open R and run:

```r
help(package = "zhulabtools")
```

This displays all functions and vignettes included in the package, with links to usage instructions and examples.

## Vignettes

Step-by-step guides, workflow recipes, and best practices are documented as vignettes.  
After installation, view available vignettes with:

```r
browseVignettes("zhulabtools")
```

Or look for the "Vignettes" section when running:

```r
help(package = "zhulabtools")
```

Vignettes include workflows for file archiving, batch downloads, and managing data on Turbo, Data Den, and the U-M cluster. You can copy and paste commands directly from each vignette—no separate shell scripts required.

## Contributing

Contributions to documentation, new functions, or improved workflows are welcome. Please open an issue or pull request.
