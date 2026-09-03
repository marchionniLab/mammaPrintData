## Regenerate `seventyGeneSignature` from the van 't Veer et al. (2002)
## supplementary spreadsheet 415530a-s9.xls (Nature 415:530, Table S2).
## Run from the package root: Rscript data-raw/seventyGeneSignature.R
## Ported from the original Sweave vignette (chunks read70genes/read70genes2).

source("data-raw/helpers.R")

xls <- seventyGeneXls()

## Read the Excel file with the 231 prognostic reporters
gns231 <- readxl::read_xls(xls)
## Clean the column headers (white spaces and "#" in the Excel file)
colnames(gns231) <- gsub("\\s#", "", colnames(gns231))
colnames(gns231) <- gsub("\\s", ".", colnames(gns231))
## Remove the GO/SwissProt keyword annotation
gns231 <- gns231[
  ,
  -grep("sp_xref_keyword_list", colnames(gns231), fixed = TRUE)
]
## Reorder the reporters by decreasing absolute correlation
gns231 <- gns231[order(abs(gns231$correlation), decreasing = TRUE), ]
## The optimal 70-gene signature: top 70 reporters by absolute correlation
gns231$signature70 <- seq_len(nrow(gns231)) <= 70

seventyGeneSignature <- as.data.frame(gns231, stringsAsFactors = FALSE)
rownames(seventyGeneSignature) <- NULL
stopifnot(
  identical(nrow(seventyGeneSignature), 231L),
  identical(sum(seventyGeneSignature$signature70), 70L),
  identical(
    colnames(seventyGeneSignature),
    c("accession", "correlation", "gene.name", "description", "signature70")
  )
)
str(seventyGeneSignature)

checkAgainstShipped(seventyGeneSignature, "seventyGeneSignature")
usethis::use_data(seventyGeneSignature, compress = "xz", overwrite = TRUE)
