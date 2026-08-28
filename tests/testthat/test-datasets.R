rgDatasets <- list(
  glasRGcy5 = c(1900L, 162L),
  glasRGcy3 = c(1900L, 162L),
  buyseRGcy5 = c(1900L, 307L),
  buyseRGcy3 = c(1900L, 307L)
)

test_that("RGList data sets have the expected structure", {
  skip_if_not_installed("limma")
  for (name in names(rgDatasets)) {
    x <- get(name, envir = asNamespace("mammaPrintData"))
    expect_true(inherits(x, "RGList"))
    expect_identical(dim(x), rgDatasets[[name]], info = name)
    expect_true(
      all(c("R", "G", "Rb", "Gb", "targets", "genes") %in% names(x)),
      info = name
    )
    expect_s3_class(x$targets, "data.frame")
    expect_s3_class(x$genes, "data.frame")
    expect_identical(nrow(x$targets), ncol(x$R), info = name)
    expect_identical(nrow(x$genes), nrow(x$R), info = name)
    expect_true(
      all(c("genes231", "genes70", "gns231Cors") %in% colnames(x$genes)),
      info = name
    )
  }
})

test_that("dye-swap pairs describe the same arrays in the same order", {
  expect_identical(colnames(buyseRGcy5$R), colnames(buyseRGcy3$R))
  expect_identical(
    buyseRGcy5$targets$Sample.Name,
    buyseRGcy3$targets$Sample.Name
  )
  ## Glas: the two sets hold the two hybridizations of the same slide
  slide <- function(x) vapply(strsplit(x, "_", fixed = TRUE), `[`, "", 2L)
  expect_identical(
    slide(glasRGcy5$targets$Scan.Name),
    slide(glasRGcy3$targets$Scan.Name)
  )
  expect_true(all(glasRGcy5$targets$Scan.Name != glasRGcy3$targets$Scan.Name))
})

test_that("curated clinical end points are present", {
  expect_true(all(
    c(
      "OS",
      "OSevent",
      "TTM",
      "TTMevent",
      "FiveYearMetastasis",
      "putativeCohort"
    ) %in%
      colnames(glasRGcy5$targets)
  ))
  expect_true(all(
    c(
      "OS",
      "OSevent",
      "DFS",
      "DFSevent",
      "TTM",
      "TTMevent",
      "FiveYearRecurrence",
      "toExclude"
    ) %in%
      colnames(buyseRGcy5$targets)
  ))
})

test_that("seventyGeneSignature is the 231-reporter table with 70 flagged", {
  expect_s3_class(seventyGeneSignature, "data.frame")
  expect_identical(nrow(seventyGeneSignature), 231L)
  expect_identical(
    colnames(seventyGeneSignature),
    c("accession", "correlation", "gene.name", "description", "signature70")
  )
  expect_identical(sum(seventyGeneSignature$signature70), 70L)
  expect_false(is.unsorted(rev(abs(seventyGeneSignature$correlation))))
  expect_false(anyDuplicated(seventyGeneSignature$accession) > 0)
})

test_that("fetchMammaPrintRaw() validates its arguments without network access", {
  expect_error(
    fetchMammaPrintRaw("E-TABM-77", source = "zenodo", cache = NULL),
    "Zenodo|zenodo"
  )
  expect_error(
    fetchMammaPrintRaw("seventyGene", source = "biostudies", cache = NULL),
    "only available from Zenodo"
  )
  expect_error(fetchMammaPrintRaw("bogus"))
})
