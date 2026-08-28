## Regenerate `buyseRGcy5` and `buyseRGcy3`: the Buyse et al. (2006) TRANSBIG
## cohort, ArrayExpress accession E-TABM-77 (307 patients, dye-swap design).
## Run from the package root, after data-raw/seventyGeneSignature.R:
##   Rscript data-raw/buyseRG.R
## Ported from the original Sweave vignette (chunks readETAB77pheno to
## substitutePhenoBuyse).

source("data-raw/helpers.R")
suppressPackageStartupMessages(library(limma))

rawDir <- mammaPrintRawDir("E-TABM-77")
progSig <- prognosticSignatureLists()

## ---- Phenotypic information (SDRF) -------------------------------------
targets <- read.table(
  file.path(rawDir, "E-TABM-77.sdrf.txt.gz"),
  comment.char = "",
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE
)
targets <- targets[, apply(targets, 2, function(x) length(unique(x)) != 1)]
targets <- targets[
  order(targets$Array.Data.File, decreasing = TRUE, method = "radix"),
]
colnames(targets) <- gsub("\\.$", "", gsub("\\.\\.", ".", colnames(targets)))
## Complete SDRF: one row per channel, 307 patients x 2 channels x 2 hybs
stopifnot(
  nrow(targets) == 1228,
  length(unique(targets$Array.Data.File)) == 614,
  sum(targets$Sample.Name != "MRP") == 614
)
rawFiles <- list.files(rawDir, pattern = "^US")
stopifnot(all(paste0(targets$Array.Data.File, ".gz") %in% rawFiles))

## Split the rows by CANCER vs REFERENCE sample and by channel
caList <- !targets$Sample.Name == "MRP"
targetsCa <- targets[caList, ]
targetsCa.ch1 <- targetsCa[targetsCa$Label == "Cy5", ]
colnames(targetsCa.ch1) <- paste(colnames(targetsCa.ch1), "Cy5", sep = ".")
targetsCa.ch2 <- targetsCa[targetsCa$Label == "Cy3", ]
colnames(targetsCa.ch2) <- paste(colnames(targetsCa.ch2), "Cy3", sep = ".")
refList <- targets$Sample.Name == "MRP"
targetsRef <- targets[refList, ]
targetsRef.ch1 <- targetsRef[targetsRef$Label == "Cy5", ]
colnames(targetsRef.ch1) <- paste(colnames(targetsRef.ch1), "Cy5", sep = ".")
targetsRef.ch2 <- targetsRef[targetsRef$Label == "Cy3", ]
colnames(targetsRef.ch2) <- paste(colnames(targetsRef.ch2), "Cy3", sep = ".")

## Combine the two channels of each hybridization into one targets row.
## Swap set 1: patient RNA in Cy5, reference in Cy3
stopifnot(all(
  targetsCa.ch1$Array.Data.File.Cy5 == targetsRef.ch2$Array.Data.File.Cy3
))
colsSel <- apply(targetsCa.ch1 == targetsRef.ch2, 2, function(x) {
  sum(x) != length(x)
})
targetsSwap1 <- cbind(
  targetsCa.ch1,
  targetsRef.ch2[, colsSel],
  stringsAsFactors = FALSE
)
targetsSwap1 <- targetsSwap1[, apply(targetsSwap1, 2, function(x) {
  length(unique(x)) != 1
})]
targetsSwap1$Cy5 <- targetsSwap1$Sample.Name
targetsSwap1$Cy3 <- "Ref"
targetsSwap1 <- targetsSwap1[, order(colnames(targetsSwap1))]
colnames(targetsSwap1) <- gsub("\\.Cy5$", "", colnames(targetsSwap1))
targetsSwap1 <- targetsSwap1[order(targetsSwap1$Cy5, method = "radix"), ]
## Swap set 2: patient RNA in Cy3, reference in Cy5
stopifnot(all(
  targetsCa.ch2$Array.Data.File.Cy3 == targetsRef.ch1$Array.Data.File.Cy5
))
colsSel <- apply(targetsCa.ch2 == targetsRef.ch1, 2, function(x) {
  sum(x) != length(x)
})
targetsSwap2 <- cbind(
  targetsCa.ch2,
  targetsRef.ch1[, colsSel],
  stringsAsFactors = FALSE
)
targetsSwap2 <- targetsSwap2[, apply(targetsSwap2, 2, function(x) {
  length(unique(x)) != 1
})]
targetsSwap2$Cy5 <- "Ref"
targetsSwap2$Cy3 <- targetsSwap2$Sample.Name
targetsSwap2 <- targetsSwap2[, order(colnames(targetsSwap2))]
colnames(targetsSwap2) <- gsub("\\.Cy3$", "", colnames(targetsSwap2))
targetsSwap2 <- targetsSwap2[order(targetsSwap2$Cy3, method = "radix"), ]
stopifnot(nrow(targetsSwap1) == 307, nrow(targetsSwap2) == 307)

## ---- RGList objects, one per dye-swap set ------------------------------
## Swap set 1 has the reference RNA in the Cy3 channel
RGcy3 <- readRawRG(targetsSwap1, rawDir)
colnames(RGcy3) <- paste("BC", targetsSwap1$Sample.Name, sep = ".")
## Swap set 2 has the reference RNA in the Cy5 channel
## NB: the original vignette text read the swap-1 file list here as well (a
## typo); the shipped objects were built from the swap-2 file list.
RGcy5 <- readRawRG(targetsSwap2, rawDir)
colnames(RGcy5) <- paste("BC", targetsSwap2$Sample.Name, sep = ".")
stopifnot(all(dim(RGcy3) == c(1900, 307)), all(dim(RGcy5) == c(1900, 307)))

## `logRatio` is numeric for this series (no "null" strings); the conversion
## shown in the original vignette (chunk checkMode2) is therefore a no-op.
convertLogRatio <- FALSE
if (convertLogRatio) {
  RGcy3$logRatio <- apply(RGcy3$logRatio, 2, as.numeric)
  RGcy5$logRatio <- apply(RGcy5$logRatio, 2, as.numeric)
}

## ---- Feature annotation (A-MEXP-318 ADF) -------------------------------
genes <- read.table(
  file.path(rawDir, "A-MEXP-318.adf.txt.gz"),
  comment.char = "",
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
buyseRGcy3 <- attachAnnotation(RGcy3, genes)
buyseRGcy5 <- attachAnnotation(RGcy5, genes)

## ---- Clinical end points (both sets) -----------------------------------
phenoBuyseCy3 <- buyseRGcy3$targets
phenoBuyseCy5 <- buyseRGcy5$targets
curateEndpoints <- function(pheno) {
  ## Overall survival: "x years" or "x years plus" (censored)
  OS <- pheno$Factor.Value.SurvivalTime
  pheno$OS <- as.numeric(gsub("\\s.+", "", OS))
  pheno$OSevent <- 1 * (!1:nrow(pheno) %in% grep("plus", OS))
  pheno$TenYearSurv <- pheno$OS < 10 & pheno$OSevent == 1
  ## Disease-free survival
  DFS <- pheno$Factor.Value.Disease.Free.Survival
  pheno$DFS <- as.numeric(gsub("\\s.+", "", DFS))
  pheno$DFSevent <- 1 * (!1:nrow(pheno) %in% grep("plus", DFS))
  pheno$FiveYearDiseaseFree <- pheno$DFS < 5 & pheno$DFSevent == 1
  ## Time to distant metastasis
  TTM <- pheno$Factor.Value.DistantMetastasis.Free.Survival
  pheno$TTM <- as.numeric(gsub("\\s.+", "", TTM))
  pheno$TTMevent <- 1 * (!1:nrow(pheno) %in% grep("plus", TTM))
  pheno$FiveYearRecurrence <- pheno$TTM < 5 & pheno$TTMevent == 1
  ## Patients excluded in the original analysis (unknown ER status)
  pheno$toExclude <- pheno$Factor.Value.ER.status == "unknown"
  pheno
}
phenoBuyseCy5 <- curateEndpoints(phenoBuyseCy5)
phenoBuyseCy3 <- curateEndpoints(phenoBuyseCy3)
print(table(
  phenoBuyseCy5$FiveYearRecurrence,
  phenoBuyseCy5$Characteristics.BioSourceProvider
))
buyseRGcy3$targets <- phenoBuyseCy3
buyseRGcy5$targets <- phenoBuyseCy5

## ---- Regression gate and save ------------------------------------------
checkAgainstShipped(buyseRGcy5, "buyseRGcy5", legacyFile = "data/buyseRG.rda")
checkAgainstShipped(buyseRGcy3, "buyseRGcy3", legacyFile = "data/buyseRG.rda")
usethis::use_data(buyseRGcy5, buyseRGcy3, compress = "xz", overwrite = TRUE)
