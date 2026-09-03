# mammaPrintData

<!-- badges: start -->
<!-- badges: end -->

Curated gene expression data from the two breast cancer cohorts used to
implement and validate the MammaPrint 70-gene prognostic signature:

- the Glas et al. (2006) implementation study, ArrayExpress `E-TABM-115`
  (162 patients), provided as `glasRGcy5` and `glasRGcy3`;
- the Buyse et al. (2006) TRANSBIG validation study, ArrayExpress
  `E-TABM-77` (307 patients), provided as `buyseRGcy5` and `buyseRGcy3`.

Both cohorts were profiled on the custom two-color Agilent 1.9k MammaPrint
array (`A-MEXP-318`) with a dye-swap design; each data set is a pair of
`limma` `RGList` objects (one per dye orientation) with probe annotation and
clinical information attached. The 70-gene signature itself is available as
the `seventyGeneSignature` data set.

## Installation

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install("mammaPrintData")
```

## Usage

```r
library(mammaPrintData)
library(limma)

data(glasRGcy5)
data(seventyGeneSignature)
dim(glasRGcy5)
head(glasRGcy5$targets)
head(seventyGeneSignature)
```

## Raw data

The original ArrayExpress files are no longer bundled with the package. They
are archived on Zenodo (doi:10.5281/zenodo.22285418) and served per file by EBI
BioStudies; `fetchMammaPrintRaw()` downloads and caches them from either
source. The scripts that regenerate the processed objects live in
`data-raw/`.

The Zenodo record is published under CC-BY-4.0; the ArrayExpress files in it
are redistributed under the [EMBL-EBI terms of
use](https://www.ebi.ac.uk/about/terms-of-use) with attribution to the
original studies, and `415530a-s9.xls` is archived verbatim from the
supplementary material of van 't Veer et al. (2002).
