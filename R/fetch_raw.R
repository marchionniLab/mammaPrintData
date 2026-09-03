## Locations of the raw data files.
.zenodoRecordId <- "22285418"

.rawDataSources <- list(
  "E-TABM-77" = list(
    zenodo = "E-TABM-77_raw.tar.gz",
    biostudies = "https://ftp.ebi.ac.uk/biostudies/fire/E-TABM-/077/E-TABM-77/Files/",
    sdrf = "E-TABM-77.sdrf.txt",
    # the array design is served from the A-MEXP-318 tree, not from Files/
    adf = "https://ftp.ebi.ac.uk/biostudies/fire/A-MEXP-/318/A-MEXP-318/Files/A-MEXP-318.adf.txt"
  ),
  "E-TABM-115" = list(
    zenodo = "E-TABM-115_raw.tar.gz",
    biostudies = "https://ftp.ebi.ac.uk/biostudies/fire/E-TABM-/115/E-TABM-115/Files/",
    sdrf = "E-TABM-115.sdrf.txt",
    adf = "https://ftp.ebi.ac.uk/biostudies/fire/A-MEXP-/318/A-MEXP-318/Files/A-MEXP-318.adf.txt"
  ),
  "seventyGene" = list(
    zenodo = "415530a-s9.xls",
    biostudies = NULL,
    sdrf = NULL,
    adf = NULL
  )
)


.zenodoFileURL <- function(file) {
  sprintf(
    "https://zenodo.org/records/%s/files/%s?download=1",
    .zenodoRecordId,
    file
  )
}

#' Retrieve the raw data behind the mammaPrintData data sets
#'
#' @description
#' Downloads (once) and caches the original files from which the processed
#' data sets of this package were generated, and returns their local paths:
#'
#' - `"E-TABM-115"`: the Glas et al. (2006) cohort ([glasRGcy5],
#'   [glasRGcy3]): SDRF sample table, `A-MEXP-318` array design (ADF) and
#'   324 Agilent Feature Extraction raw files;
#' - `"E-TABM-77"`: the Buyse et al. (2006) cohort ([buyseRGcy5],
#'   [buyseRGcy3]): SDRF, ADF and 614 raw files;
#' - `"seventyGene"`: the van 't Veer et al. (2002) supplementary table
#'   `415530a-s9.xls` behind [seventyGeneSignature].
#'
#' Two sources are available:
#'
#' - `"zenodo"` (recommended): one gzip-compressed tar archive per
#'   ArrayExpress accession (`E-TABM-115_raw.tar.gz`, 70 MB, and
#'   `E-TABM-77_raw.tar.gz`, 134 MB), each containing the SDRF, the ADF and
#'   all gzipped raw files exactly as originally retrieved from
#'   ArrayExpress, plus the spreadsheet. The function returns the path to the
#'   archive (or spreadsheet); extract it with [utils::untar()]. Files are
#'   served from Zenodo record \doi{10.5281/zenodo.22285418}. The record is published under CC-BY-4.0
#'   with per-file provenance (see the package-level help).
#' - `"biostudies"`: the per-file tree served by EBI BioStudies (the current
#'   home of ArrayExpress). Only the SDRF and the ADF are downloaded by
#'   default; individual raw files (uncompressed, several hundred of them
#'   per accession, about 820 KB each) can be requested with `files`. The
#'   spreadsheet is not available from this source.
#'
#' Downloads are managed by `BiocFileCache`, so repeated calls return the
#' cached copies without touching the network.
#'
#' @param accession Which resource to fetch: `"E-TABM-77"`, `"E-TABM-115"`
#'   or `"seventyGene"`.
#' @param source `"zenodo"` (default) or `"biostudies"`.
#' @param files Only for `source = "biostudies"`: character vector of raw
#'   file names to download in addition to the SDRF and ADF (as listed in
#'   the `Array Data File` column of the SDRF; a trailing `.gz` is
#'   tolerated), or `"all"` for the complete set. Ignored for Zenodo.
#' @param cache A [BiocFileCache::BiocFileCache] object. Defaults to the
#'   user's default cache.
#' @param verbose Logical, print download messages.
#' @returns A named character vector with the local paths of the requested
#'   files. Names are the original file names.
#' @seealso [BiocFileCache::bfcrpath()], [utils::untar()]
#' @examplesIf interactive()
#' ## The Buyse cohort archive from Zenodo (134 MB, downloaded once)
#' archive <- fetchMammaPrintRaw("E-TABM-77")
#' rawDir <- tempfile("E-TABM-77_")
#' untar(archive, exdir = rawDir)
#' list.files(rawDir, recursive = TRUE)[1:5]
#'
#' ## The sample table and array design only, from BioStudies
#' meta <- fetchMammaPrintRaw("E-TABM-115", source = "biostudies")
#' sdrf <- read.delim(meta[["E-TABM-115.sdrf.txt"]], check.names = FALSE)
#' head(sdrf[["Array Data File"]])
#'
#' ## Two raw files from BioStudies
#' fetchMammaPrintRaw("E-TABM-115",
#'   source = "biostudies",
#'   files = sdrf[["Array Data File"]][1:2]
#' )
#' @export
fetchMammaPrintRaw <- function(
  accession = c("E-TABM-77", "E-TABM-115", "seventyGene"),
  source = c("zenodo", "biostudies"),
  files = NULL,
  cache = BiocFileCache::BiocFileCache(),
  verbose = interactive()
) {
  accession <- match.arg(accession)
  source <- match.arg(source)
  info <- .rawDataSources[[accession]]

  if (source == "zenodo") {
    if (!is.null(files)) {
      warning(
        "'files' is ignored for source = \"zenodo\"; the whole archive is fetched"
      )
    }
    return(.cachedDownload(
      cache,
      .zenodoFileURL(info$zenodo),
      info$zenodo,
      verbose
    ))
  }

  ## BioStudies
  if (is.null(info$biostudies)) {
    stop(
      "'",
      accession,
      "' is only available from Zenodo (source = \"zenodo\")",
      call. = FALSE
    )
  }
  urls <- c(paste0(info$biostudies, info$sdrf), info$adf)
  paths <- .cachedDownload(cache, urls, basename(urls), verbose)
  if (!is.null(files)) {
    sdrf <- utils::read.delim(
      paths[[1L]],
      check.names = FALSE,
      stringsAsFactors = FALSE,
      comment.char = ""
    )
    available <- unique(sdrf[["Array Data File"]])
    if (identical(files, "all")) {
      files <- available
    } else {
      files <- sub("\\.gz$", "", as.character(files))
      unknown <- setdiff(files, available)
      if (length(unknown)) {
        stop(
          "Unknown raw file(s) for ",
          accession,
          ": ",
          paste(unknown, collapse = ", "),
          call. = FALSE
        )
      }
    }
    paths <- c(
      paths,
      .cachedDownload(cache, paste0(info$biostudies, files), files, verbose)
    )
  }
  paths
}

## Download `urls` through BiocFileCache (the URL is used as resource name,
## so that a resource is downloaded only once per cache) and return the local
## paths, named by `names`.
.cachedDownload <- function(cache, urls, names, verbose) {
  paths <- vapply(
    urls,
    function(u) {
      withCallingHandlers(
        BiocFileCache::bfcrpath(cache, rnames = u),
        message = function(cond) {
          # BiocFileCache reports e.g. "adding rname '<url>'"; keep those
          # progress messages only when verbose, muffle them otherwise.
          if (!verbose) {
            invokeRestart("muffleMessage")
          }
        }
      )
    },
    character(1L),
    USE.NAMES = FALSE
  )
  names(paths) <- names
  paths
}
