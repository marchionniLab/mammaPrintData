## Regenerate `glasRGcy5` and `glasRGcy3`: the Glas et al. (2006) cohort,
## ArrayExpress accession E-TABM-115 (162 patients, dye-swap design).
## Run from the package root, after data-raw/seventyGeneSignature.R:
##   Rscript data-raw/glasRG.R
## Ported from the original Sweave vignette (chunks readETAB115pheno to
## substitutePhenoGlas).

source("data-raw/helpers.R")
suppressPackageStartupMessages(library(limma))

rawDir <- mammaPrintRawDir("E-TABM-115")
progSig <- prognosticSignatureLists()

## ---- Phenotypic information (SDRF) -------------------------------------
targets <- read.table(
  file.path(rawDir, "E-TABM-115.sdrf.txt.gz"),
  comment.char = "",
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)
## Keep non-redundant information only
targets <- targets[, apply(targets, 2, function(x) length(unique(x)) != 1)]
## Reorder by file name
targets <- targets[
  order(targets$Array.Data.File, decreasing = TRUE, method = "radix"),
]
## Clean column names
colnames(targets) <- gsub("\\.$", "", gsub("\\.\\.", ".", colnames(targets)))
## The SDRF has one row per hybridization (324) rather than one per channel:
## half of the rows describe the patient RNA (Cy5) with clinical information,
## the other half the "MRP" reference pool (Cy3) without it.
stopifnot(
  nrow(targets) == 324,
  table(targets$Label) == 162,
  is.na(targets$Characteristics.EventDistantMetastases) ==
    (targets$Sample.Name == "MRP")
)

## ---- RGList objects, one per dye-swap set ------------------------------
rawFiles <- list.files(rawDir, pattern = "^US")
stopifnot(paste0(targets$Array.Data.File, ".gz") %in% rawFiles)
## Hybridizations described through the reference RNA labeled with Cy3
targetsCy3info <- targets[
  targets$Source.Name == "MRP" & targets$Label == "Cy3",
]
## Hybridizations described through the patient RNA labeled with Cy5
targetsCy5info <- targets[
  targets$Source.Name != "MRP" & targets$Label == "Cy5",
]
stopifnot(
  nrow(targetsCy3info) == 162,
  nrow(targetsCy5info) == 162,
  targetsCy3info$Array.Data.File != targetsCy5info$Array.Data.File
)
RGcy3 <- readRawRG(targetsCy3info, rawDir)
## NB: the original vignette text read the Cy3 file list here as well (a
## typo); the shipped objects were built from the Cy5 file list.
RGcy5 <- readRawRG(targetsCy5info, rawDir)
stopifnot(dim(RGcy3) == c(1900, 162), dim(RGcy5) == c(1900, 162))

## The "LogRatio" column contains a few "null" strings in this series, so
## `logRatio` is read as a character matrix. The original vignette showed a
## conversion to numeric (chunk checkMode1) that was NOT applied to the
## shipped objects; it is kept disabled to reproduce them exactly.
convertLogRatio <- FALSE
if (convertLogRatio) {
  RGcy3$logRatio <- apply(RGcy3$logRatio, 2, as.numeric)
  RGcy5$logRatio <- apply(RGcy5$logRatio, 2, as.numeric)
}

## ---- Feature annotation (A-MEXP-318 ADF) -------------------------------
genes <- read.table(
  file.path(rawDir, "A-MEXP-318.adf.txt.gz"),
  skip = 21,
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)
colnames(genes) <- gsub("\\.$", "", gsub("\\.\\.", ".", colnames(genes)))
genes <- annotateSignature(genes, progSig)
message(
  "Features mapped to the 231-gene / 70-gene lists: ",
  sum(genes$genes231),
  " / ",
  sum(genes$genes70)
)
glasRGcy3 <- attachAnnotation(RGcy3, genes)
glasRGcy5 <- attachAnnotation(RGcy5, genes)

## ---- Clinical end points -----------------------------------------------
phenoGlasCy3 <- glasRGcy3$targets
phenoGlasCy5 <- glasRGcy5$targets
## Putative cohort of origin (78 van 't Veer + 84 Van de Vijver cases),
## inferred from the 1-digit vs 3-digit suffix of the scan names
print(table(
  gsub(".+_", "", phenoGlasCy3$Scan.Name) ==
    gsub(".+_", "", phenoGlasCy5$Scan.Name)
))
phenoGlasCy5$putativeCohort <- factor(nchar(gsub(
  ".+_",
  "",
  phenoGlasCy5$Scan.Name
)))
levels(phenoGlasCy5$putativeCohort) <- c(
  "putativeVantVeer",
  "putativeVanDeVijver"
)
phenoGlasCy3$putativeCohort <- factor(nchar(gsub(
  ".+_",
  "",
  phenoGlasCy3$Scan.Name
)))
levels(phenoGlasCy3$putativeCohort) <- c(
  "putativeVantVeer",
  "putativeVanDeVijver"
)
print(table(phenoGlasCy5$putativeCohort))
## Overall survival (clinical information is available for the Cy5 set only)
OS <- gsub("\\s.+", "", phenoGlasCy5$Factor.Value.overall_survival)
phenoGlasCy5$OS <- as.numeric(OS)
phenoGlasCy5$OSevent <- as.numeric(phenoGlasCy5$Factor.Value.Event_Death)
phenoGlasCy5$TenYearSurv <- phenoGlasCy5$OS < 10 & phenoGlasCy5$OSevent == 1
phenoGlasCy5$TenYearSurv[is.na(phenoGlasCy5$OSevent)] <- NA
## Time to distant metastasis
TTM <- phenoGlasCy5$Factor.Value.Time_to_development_of_distant_metastases
phenoGlasCy5$TTM <- as.numeric(gsub("\\s.+", "", TTM))
phenoGlasCy5$TTMevent <- as.numeric(
  phenoGlasCy5$Factor.Value.Event_distant_metastases
)
## Use the OS follow-up time as TTM for patients without metastasis
phenoGlasCy5$TTM[is.na(phenoGlasCy5$TTM)] <- phenoGlasCy5$OS[is.na(
  phenoGlasCy5$TTM
)]
phenoGlasCy5$FiveYearMetastasis <- phenoGlasCy5$TTM < 5 &
  phenoGlasCy5$TTMevent == 1
print(table(phenoGlasCy5$FiveYearMetastasis, phenoGlasCy5$putativeCohort))
glasRGcy3$targets <- phenoGlasCy3
glasRGcy5$targets <- phenoGlasCy5

## ---- Regression gate and save ------------------------------------------
checkAgainstShipped(glasRGcy5, "glasRGcy5", legacyFile = "data/glasRG.rda")
checkAgainstShipped(glasRGcy3, "glasRGcy3", legacyFile = "data/glasRG.rda")
usethis::use_data(glasRGcy5, glasRGcy3, compress = "xz", overwrite = TRUE)
