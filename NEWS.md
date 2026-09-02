# Changes in version 1.99.0

## Data distribution

- The raw ArrayExpress files (E-TABM-115 for the Glas cohort, E-TABM-77 for
  the Buyse cohort; about 210 MB) are no longer bundled in `inst/extdata`.
  They are archived on Zenodo (doi:[ZENODO_DOI]) and remain available per
  file from EBI BioStudies. The new exported function `fetchMammaPrintRaw()`
  retrieves them from either source and caches the downloads with
  `BiocFileCache`.
- Each data set is now stored in its own xz-compressed `.rda` file, one
  object per file, loaded explicitly with `data()` (`LazyData: false`, as
  recommended by Bioconductor for data packages). The legacy combined files
  `data/glasRG.rda` and `data/buyseRG.rda` were removed, so `data(glasRG)`
  and `data(buyseRG)` no longer work; call `data(glasRGcy5)`,
  `data(glasRGcy3)`, `data(buyseRGcy5)` or `data(buyseRGcy3)` instead.
- New processed data set `seventyGeneSignature`: the 231 prognostic
  reporters of van 't Veer et al. (2002, Nature 415:530), Table S2, with the
  70-gene MammaPrint signature flagged, parsed from the supplementary
  spreadsheet `415530a-s9.xls`.

## Documentation

- All documentation is now generated with roxygen2 (Markdown mode); the
  hand-written `man/*.Rd` files were removed.
- The vignette was rewritten in R Markdown (`BiocStyle`, `knitr`). It no
  longer processes the raw data at build time; the full data-generation
  code lives in `data-raw/` (build-ignored) and is summarized in the
  vignette.

## Package infrastructure

- Removed `renv`, `.Rprofile`, `INDEX`, `external_data_store.txt` and
  `data/datalist`.
- DESCRIPTION modernized: `Authors@R`, `LazyData`, `Imports`/`Suggests`
  cleanup, GitHub `URL`/`BugReports`.
- Git history: the oversized archives `E-TABM-77.raw.1.zip` and
  `E-TABM-115.raw.1.zip` present in the `RELEASE_3_5` lineage are being
  purged from the repository history in coordination with Bioconductor.
