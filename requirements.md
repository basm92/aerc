# R Package Requirements

All packages used across slides, notebooks, and scripts in this repository.

## CRAN Packages

```r
install.packages(c(
  "archive",
  "cbsodataR",
  "climate",
  "dplyr",
  "fixest",
  "geodata",
  "giscoR",
  "gstat",
  "here",
  "igraph",
  "igraphdata",
  "janitor",
  "kableExtra",
  "lubridate",
  "Matrix",
  "modelsummary",
  "nngeo",
  "osmdata",
  "pacman",
  "patchwork",
  "rdrobust",
  "rnaturalearth",
  "rnaturalearthdata",
  "sf",
  "spdep",
  "stars",
  "terra",
  "tidyverse",
  "tinytable"
))
```

## Bioconductor Packages

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("rhdf5")
```

## GitHub Packages

```r
# install.packages("remotes")
remotes::install_github("sfsheath/cawd")      # Historical boundary data (Roman Empire)
remotes::install_github("floswald/GAEZr")     # GAEZ raster data
remotes::install_github("basm92/spatInfer")   # Spatial inference
```
