#' mammaPrintData: gene expression data from the MammaPrint validation cohorts
#'
#' @description
#' Curated, unprocessed two-color microarray data for the two breast cancer
#' cohorts used to implement and validate the 70-gene MammaPrint prognostic
#' signature:
#'
#' - the **Glas cohort** (Glas et al. 2006, ArrayExpress accession
#'   `E-TABM-115`), 162 patients combining a large proportion of the original
#'   van 't Veer and Van de Vijver cases, used to translate the 70-gene
#'   signature into the MammaPrint assay; provided as [glasRGcy5] and
#'   [glasRGcy3];
#' - the **Buyse cohort** (Buyse et al. 2006, ArrayExpress accession
#'   `E-TABM-77`), 307 patients from the TRANSBIG European multicenter
#'   validation study; provided as [buyseRGcy5] and [buyseRGcy3].
#'
#' Both studies used the custom Agilent 1.9k MammaPrint array (`A-MEXP-318`)
#' with a dye-swap design against a common reference RNA, so each cohort is
#' shipped as two `limma` `RGList` objects, one per dye orientation, with
#' probe annotation (including the mapping to the 231-gene and 70-gene
#' prognostic lists) and patient-level clinical information attached. The
#' 70-gene signature itself is available as [seventyGeneSignature].
#'
#' @section Raw data:
#' Since version 1.99.0 the original ArrayExpress files are no longer
#' bundled with the package. They are archived on Zenodo
#' (\doi{[ZENODO_DOI]}) and remain available per file from EBI BioStudies;
#' [fetchMammaPrintRaw()] downloads them from either source and caches them
#' locally. The scripts that regenerate the processed objects from the raw
#' files are kept in the `data-raw/` directory of the package sources.
#'
#' @section Backward compatibility:
#' Each object is stored in its own file and loaded explicitly with `data()`.
#' The legacy combined files `glasRG.rda` and `buyseRG.rda` were removed, so
#' `data(glasRG)` and `data(buyseRG)` no longer work: call `data(glasRGcy5)`,
#' `data(glasRGcy3)`, `data(buyseRGcy5)` or `data(buyseRGcy3)` instead, one
#' object per call.
#'
#' @references
#' Glas AM, Floore A, Delahaye LJ, et al. Converting a breast cancer
#' microarray signature into a high-throughput diagnostic test.
#' *BMC Genomics* 2006, 7:278. \doi{10.1186/1471-2164-7-278},
#' <https://pubmed.ncbi.nlm.nih.gov/17074082/>.
#'
#' Buyse M, Loi S, van 't Veer L, et al. Validation and clinical utility of
#' a 70-gene prognostic signature for women with node-negative breast
#' cancer. *J Natl Cancer Inst* 2006, 98(17):1183-1192.
#' \doi{10.1093/jnci/djj329}, <https://pubmed.ncbi.nlm.nih.gov/16954471/>.
#'
#' van 't Veer LJ, Dai H, van de Vijver MJ, et al. Gene expression profiling
#' predicts clinical outcome of breast cancer. *Nature* 2002, 415:530-536.
#' \doi{10.1038/415530a}.
#'
#' Marchionni L, Afsari B, Geman D, Leek JT. A simple and reproducible
#' breast cancer prognostic test. *BMC Genomics* 2013, 14:336.
#' \doi{10.1186/1471-2164-14-336}.
#'
#' @seealso [limma::RGList-class]
#' @keywords internal
"_PACKAGE"
