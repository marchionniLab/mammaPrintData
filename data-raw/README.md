# data-raw

Scripts that regenerate the processed data sets shipped in `data/` from the
original raw files. They follow the `usethis::use_data_raw()` convention:
each script prepares one data set (or one dye-swap pair) and ends with
`usethis::use_data(..., compress = "xz", overwrite = TRUE)`. This directory
is listed in `.Rbuildignore` and is not part of the built package.

| Script | Input | Output |
|--------|-------|--------|
| `seventyGeneSignature.R` | `415530a-s9.xls` (van 't Veer et al. 2002, Table S2) | `data/seventyGeneSignature.rda` |
| `glasRG.R` | `E-TABM-115_raw.tar.gz` (SDRF, `A-MEXP-318` ADF, 324 raw files) + `seventyGeneSignature` | `data/glasRGcy5.rda`, `data/glasRGcy3.rda` |
| `buyseRG.R` | `E-TABM-77_raw.tar.gz` (SDRF, ADF, 614 raw files) + `seventyGeneSignature` | `data/buyseRGcy5.rda`, `data/buyseRGcy3.rda` |
| `helpers.R` | sourced by the scripts: raw-file access, shared processing steps and the regression gate | |
| `README-zenodo.md`, `MD5SUMS`, `SHA256SUMS` | description and checksums of the Zenodo deposit (raw tarballs, `415530a-s9.xls`, processed `.rda` copies) | |

Run them from the package root, in this order:

```sh
Rscript data-raw/seventyGeneSignature.R
Rscript data-raw/glasRG.R
Rscript data-raw/buyseRG.R
```

The raw inputs come from the Zenodo record doi:10.5281/zenodo.22285418 (through the
package's own `fetchMammaPrintRaw()`), or from local copies of the upload artifacts kept in this
directory (`E-TABM-*_raw.tar.gz`, `415530a-s9.xls`; all git-ignored). The same
files are served individually by EBI BioStudies (`fetchMammaPrintRaw(...,
source = "biostudies")`), which the scripts do not use because the complete
per-array set amounts to several hundred files per accession.

## Regression gate

Before overwriting `data/`, each script compares the regenerated object
with the version currently in `data/` (`checkAgainstShipped()` in
`helpers.R`): `all.equal(new, old, check.attributes = FALSE)` must be
`TRUE` and `dim()`, `names()` and the `targets` row order must be
identical, otherwise the script stops. Set the environment variable
`MAMMAPRINTDATA_FORCE_UPDATE=1` to deliberately ship a different object.

Notes on reproducing the objects originally built in 2013:

- The scripts set `LC_COLLATE` to `C`: the array order (from `order()` on
  raw file names) and the row names of the merged annotation depend on the
  collation.
- The objects were built from uncompressed `.txt` files; the `.txt` left in
  the array names by `limma::read.maimages()` (which only strips `.gz`) is
  removed.
- `logRatio`/`logRatioError` are stored as plain list components, so
  `limma` methods (`[`, `dimnames<-`) do not touch them; they are kept
  exactly as originally shipped (see the comments in `helpers.R` and the
  scripts).
- In the Glas series the `LogRatio` column contains a few `"null"` strings,
  so `logRatio` is a character matrix in `glasRGcy5`/`glasRGcy3`, as
  originally shipped (the numeric conversion shown in the old vignette was
  not applied to the shipped objects and is kept disabled).

## Last regeneration

Date: 2026-08-28. Result of the regression gate against the objects
shipped up to version 1.49.1 (legacy `glasRG.rda`/`buyseRG.rda`):

- `glasRGcy5`, `buyseRGcy5`, `buyseRGcy3`: byte-identical
  (`identical()` is `TRUE`).
- `glasRGcy3`: `all.equal()` `TRUE`; `identical()` `FALSE` because a single
  value of `logRatioError` differs in the last floating-point digit
  (`0.0652989` parsed as `0.065298900000000007` by R 4.6 vs
  `0.065298899999999993` in 2013): a decimal-parser rounding artifact.
- `seventyGeneSignature`: new data set, no previous version.

```
R version 4.6.1 (2026-06-24)
Platform: aarch64-apple-darwin23
Running under: macOS Tahoe 26.5.1

Matrix products: default
BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/New_York
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] BiocFileCache_3.2.0 dbplyr_2.6.0        usethis_3.2.1      
[4] readxl_1.5.0        limma_3.68.4       

loaded via a namespace (and not attached):
 [1] vctrs_0.7.3      cli_3.6.6        rlang_1.3.0      otel_0.2.0      
 [5] DBI_1.3.0        purrr_1.2.2      generics_0.1.4   glue_1.8.1      
 [9] bit_4.6.0        statmod_1.5.2    rappdirs_0.3.4   cellranger_1.1.0
[13] filelock_1.0.3   tibble_3.3.1     fastmap_1.2.0    lifecycle_1.0.5 
[17] httr2_1.2.3      memoise_2.0.1    compiler_4.6.1   dplyr_1.2.1     
[21] fs_2.1.0         RSQLite_3.53.3   blob_1.3.0       pkgconfig_2.0.3 
[25] R6_2.6.1         tidyselect_1.2.1 curl_7.1.0       pillar_1.11.1   
[29] magrittr_2.0.5   tools_4.6.1      bit64_4.8.2      cachem_1.1.0    
```
