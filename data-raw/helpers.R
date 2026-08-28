## Helper functions shared by the data-raw/ scripts. Not part of the package.
## Source from the package root: source("data-raw/helpers.R")

## The shipped objects were generated with C collation: the array order
## (order() on file names such as "..._S01_2._1" vs "..._S01_2_3") and the
## row names of the merged annotation depend on it. Make the scripts
## reproducible regardless of the user's locale.
invisible(Sys.setlocale("LC_COLLATE", "C"))

## Directory holding the local copies of the Zenodo upload artifacts
## (build-ignored, never committed). When it is absent the raw files are
## downloaded from Zenodo through the package's own fetchMammaPrintRaw().
depositDir <- "zenodo-deposit"

## Return a directory with the extracted raw files of one ArrayExpress
## accession (SDRF, ADF and gzipped Feature Extraction files).
mammaPrintRawDir <- function(accession = c("E-TABM-77", "E-TABM-115")) {
  accession <- match.arg(accession)
  archive <- file.path(depositDir, paste0(accession, "_raw.tar.gz"))
  if (!file.exists(archive)) {
    pkgload::load_all(".", quiet = TRUE)
    archive <- fetchMammaPrintRaw(accession, source = "zenodo")
  }
  exdir <- file.path(tempdir(), "mammaPrintData-raw")
  utils::untar(archive, exdir = exdir)
  file.path(exdir, sub("E-TABM-", "ETABM", accession, fixed = TRUE))
}

## Return the path of the van 't Veer supplementary spreadsheet.
seventyGeneXls <- function() {
  xls <- file.path(depositDir, "415530a-s9.xls")
  if (!file.exists(xls)) {
    pkgload::load_all(".", quiet = TRUE)
    xls <- fetchMammaPrintRaw("seventyGene", source = "zenodo")
  }
  xls
}

## Rebuild the `progSig` list of the original vignette (chunk read70genes2)
## from the processed seventyGeneSignature data set.
prognosticSignatureLists <- function() {
  f <- file.path("data", "seventyGeneSignature.rda")
  if (!file.exists(f)) {
    stop("Run data-raw/seventyGeneSignature.R first")
  }
  e <- new.env()
  load(f, envir = e)
  gns231 <- e$seventyGeneSignature
  gns70 <- gns231[gns231$signature70, ]
  progSig <- list(
    gns231acc = unique(gns231$accession),
    gns231name = unique(gns231$gene.name),
    gns231any = unique(c(gns231$accession, gns231$gene.name)),
    gns70acc = unique(gns70$accession),
    gns70name = unique(gns70$gene.name),
    gns70any = unique(c(gns70$accession, gns70$gene.name))
  )
  ## Remove empty elements
  progSig <- lapply(progSig, function(x) x[x != ""])
  ## Correlations keyed by gene symbol (where available) and by accession
  gns231Cors <- data.frame(
    stringsAsFactors = FALSE,
    ID = c(
      gns231$gene.name[gns231$gene.name %in% progSig$gns231any],
      gns231$accession
    ),
    gns231Cors = c(
      gns231$correlation[gns231$gene.name %in% progSig$gns231any],
      gns231$correlation
    )
  )
  ## NB: the original code also computed a de-duplicated version but then
  ## overwrote it with this one; duplicates are removed later, after the
  ## merge with the array annotation (see annotateSignature()).
  progSig$gns231Cors <- gns231Cors[gns231Cors$ID != "", ]
  progSig
}

## Columns read from the Agilent Feature Extraction files (limma "generic"
## source). `logRatio` and `logRatioError` become extra list components.
colsList <- list(
  Rf = "Feature Extraction Software:rMedianSignal",
  Rb = "Feature Extraction Software:rBGMedianSignal",
  Gf = "Feature Extraction Software:gMedianSignal",
  Gb = "Feature Extraction Software:gBGMedianSignal",
  logRatio = "Feature Extraction Software:LogRatio",
  logRatioError = "Feature Extraction Software:LogRatioError"
)

## Read one set of raw files into an RGList and attach the targets table.
readRawRG <- function(targetsInfo, rawDir) {
  RG <- suppressWarnings(
    # "non-standard columns specified" is expected
    limma::read.maimages(
      paste0(targetsInfo$Array.Data.File, ".gz"),
      source = "generic",
      columns = colsList,
      annotation = "Reporter identifier",
      path = rawDir,
      verbose = FALSE
    )
  )
  ## The objects were originally built from the uncompressed ".txt" files, so
  ## the array names carry no extension; strip the ".txt" left by
  ## read.maimages() (which only removes the ".gz") from every matrix.
  for (a in c("R", "G", "Rb", "Gb", "logRatio", "logRatioError")) {
    colnames(RG[[a]]) <- sub("\\.txt$", "", colnames(RG[[a]]))
  }
  RG$targets <- targetsInfo
  RG$genes$ID <- gsub(".+A-MEXP-318\\.", "", RG$genes[, "Reporter identifier"])
  RG
}

## Map the A-MEXP-318 features to the 231-gene and 70-gene prognostic lists
## and add the original van 't Veer correlations.
annotateSignature <- function(genes, progSig) {
  genes$genes231 <- genes$Comment.AEReporterName %in% progSig$gns231any
  genes$genes70 <- genes$Comment.AEReporterName %in% progSig$gns70any
  gns231Cors <- progSig$gns231Cors
  gns231Cors <- gns231Cors[gns231Cors$ID %in% genes$Comment.AEReporterName, ]
  genes <- merge(
    genes,
    gns231Cors,
    all.x = TRUE,
    all.y = FALSE,
    by.x = "Comment.AEReporterName",
    by.y = "ID"
  )
  genes[!duplicated(genes$Reporter.Name), ]
}

## Replace the `genes` component of an RGList with the array annotation,
## reordering the features by reporter identifier when needed.
## NB: limma's `[.RGList` only reorders the standard components (R, G, Rb,
## Gb, weights, genes); the extra `logRatio`/`logRatioError` matrices are
## left untouched. This reproduces the objects as originally shipped.
attachAnnotation <- function(RG, genes) {
  if (nrow(genes) != nrow(RG)) {
    stop("Wrong number of features, check objects")
  }
  if (!all(genes$Reporter.Name == RG$genes$ID)) {
    RG <- RG[order(RG$genes$ID), ]
    genes <- genes[order(genes$Reporter.Name), ]
    if (!all(genes$Reporter.Name == RG$genes$ID)) {
      stop("Wrong gene order, check objects")
    }
  }
  RG$genes <- genes
  RG
}

## Regression gate: compare a regenerated object with the version currently
## in data/ (per-object file, or the legacy combined file) and stop if they
## differ, unless MAMMAPRINTDATA_FORCE_UPDATE is set.
checkAgainstShipped <- function(new, name, legacyFile = NULL) {
  f <- file.path("data", paste0(name, ".rda"))
  if (!file.exists(f) && !is.null(legacyFile)) {
    f <- legacyFile
  }
  if (!file.exists(f)) {
    message(
      name,
      ": no previous version found in data/, regression check skipped"
    )
    return(invisible(NA))
  }
  e <- new.env()
  load(f, envir = e)
  old <- get(name, envir = e)
  isIdentical <- identical(new, old)
  ae <- all.equal(new, old, check.attributes = FALSE)
  sameDim <- identical(dim(new), dim(old))
  sameNames <- identical(names(new), names(old))
  sameRows <- identical(rownames(new$targets), rownames(old$targets))
  message(sprintf(
    "%s vs %s: identical = %s; all.equal(check.attributes = FALSE) = %s; dim = %s; names = %s; targets row order = %s",
    name,
    f,
    isIdentical,
    isTRUE(ae),
    sameDim,
    sameNames,
    sameRows
  ))
  if (!(isTRUE(ae) && sameDim && sameNames && sameRows)) {
    print(ae)
    if (!nzchar(Sys.getenv("MAMMAPRINTDATA_FORCE_UPDATE"))) {
      stop(
        "Regenerated '",
        name,
        "' differs from the shipped version. ",
        "Inspect the differences; set MAMMAPRINTDATA_FORCE_UPDATE=1 to overwrite."
      )
    }
    warning(
      "Overwriting '",
      name,
      "' with a different object (MAMMAPRINTDATA_FORCE_UPDATE set)"
    )
  }
  invisible(isIdentical)
}
