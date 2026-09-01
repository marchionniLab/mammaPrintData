## Shared text for the RGList component lists is repeated verbatim in each
## block so that every help page is self-contained.

#' Glas cohort (E-TABM-115): hybridizations with patient RNA labeled with Cy5
#'
#' @description
#' A `limma` `RGList` with the raw two-color intensities for the 162 breast
#' cancer patients of the Glas et al. (2006) study, restricted to the set of
#' dye-swap hybridizations in which the information provided in the
#' ArrayExpress SDRF table refers to the RNA sample labeled with Cy5 (the
#' reference pool "MRP" being labeled with Cy3). The clinical information
#' available from ArrayExpress is attached to this set only; see
#' [glasRGcy3] for the swapped hybridizations.
#'
#' @format
#' An `RGList` (see [limma::RGList-class]) with 1900 microarray features and
#' 162 arrays. Components:
#'
#' - `R`, `Rb`: raw median foreground and background intensities of the red
#'   channel;
#' - `G`, `Gb`: raw median foreground and background intensities of the
#'   green channel;
#' - `logRatio`, `logRatioError`: the log ratio between the red and green
#'   channels and its error, as reported in the raw Feature Extraction
#'   files (stored as plain list components, not in `other`);
#' - `targets`: a `data.frame` with one row per array holding the SDRF
#'   information (sample names, labels, hybridization and scan names, raw
#'   file names) together with the curated clinical end points
#'   `putativeCohort` (van 't Veer or Van de Vijver origin, inferred from the
#'   scan name suffix), `OS` (overall survival, years), `OSevent`,
#'   `TenYearSurv`, `TTM` (time to distant metastasis, years), `TTMevent`
#'   and `FiveYearMetastasis`;
#' - `genes`: a `data.frame` with the `A-MEXP-318` array design annotation
#'   (`Reporter.Name`, `Comment.AEReporterName`, database entries, control
#'   type, grid position) plus `genes231` and `genes70` (logical membership
#'   in the 231-gene and 70-gene prognostic lists) and `gns231Cors` (the
#'   original van 't Veer correlation with outcome, where available);
#' - `source`: `"generic"`.
#'
#' @source ArrayExpress/BioStudies accession E-TABM-115,
#'   <https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-TABM-115>;
#'   raw files archived on Zenodo, \doi{[ZENODO_DOI]} (see
#'   [fetchMammaPrintRaw()]).
#' @references
#' Glas AM, Floore A, Delahaye LJ, et al. Converting a breast cancer
#' microarray signature into a high-throughput diagnostic test.
#' *BMC Genomics* 2006, 7:278. \doi{10.1186/1471-2164-7-278},
#' <https://pubmed.ncbi.nlm.nih.gov/17074082/>.
#' @seealso [glasRGcy3], [buyseRGcy5], [seventyGeneSignature],
#'   [limma::RGList-class]
#' @examples
#' library(limma)
#' class(glasRGcy5)
#' dim(glasRGcy5)
#' head(glasRGcy5$targets, n = 5)
#' head(glasRGcy5$genes, n = 5)
#' table(glasRGcy5$targets$FiveYearMetastasis, useNA = "ifany")
"glasRGcy5"

#' Glas cohort (E-TABM-115): hybridizations with patient RNA labeled with Cy3
#'
#' @description
#' A `limma` `RGList` with the raw two-color intensities for the 162 breast
#' cancer patients of the Glas et al. (2006) study, restricted to the set of
#' dye-swap hybridizations in which the information provided in the
#' ArrayExpress SDRF table refers to the reference pool "MRP" labeled with
#' Cy3. The SDRF table available from ArrayExpress does not report the
#' clinical information for this set of hybridizations (its rows describe
#' the reference channel), hence `targets` only carries the reference-pool
#' and hybridization metadata plus the inferred `putativeCohort`. The
#' arrays are in the same order as in [glasRGcy5], which holds the clinical
#' information of the corresponding patients.
#'
#' @format
#' An `RGList` (see [limma::RGList-class]) with 1900 microarray features and
#' 162 arrays. Components:
#'
#' - `R`, `Rb`: raw median foreground and background intensities of the red
#'   channel;
#' - `G`, `Gb`: raw median foreground and background intensities of the
#'   green channel;
#' - `logRatio`, `logRatioError`: the log ratio between the red and green
#'   channels and its error, as reported in the raw Feature Extraction
#'   files (stored as plain list components, not in `other`);
#' - `targets`: a `data.frame` with one row per array holding the SDRF
#'   information for the reference channel (hybridization and scan names,
#'   raw file names) and `putativeCohort`;
#' - `genes`: a `data.frame` with the `A-MEXP-318` array design annotation
#'   plus `genes231`, `genes70` and `gns231Cors` (see [glasRGcy5]);
#' - `source`: `"generic"`.
#'
#' @inherit glasRGcy5 source references
#' @seealso [glasRGcy5], [buyseRGcy3], [seventyGeneSignature],
#'   [limma::RGList-class]
#' @examples
#' library(limma)
#' class(glasRGcy3)
#' dim(glasRGcy3)
#' head(glasRGcy3$targets, n = 5)
#' ## arrays are paired with glasRGcy5 by position
#' all(glasRGcy3$targets$Hybridization.Name != glasRGcy5$targets$Hybridization.Name)
"glasRGcy3"

#' Buyse cohort (E-TABM-77): hybridizations with the reference RNA labeled with Cy5
#'
#' @description
#' A `limma` `RGList` with the raw two-color intensities for the 307 breast
#' cancer patients of the Buyse et al. (2006) TRANSBIG validation study,
#' restricted to the set of dye-swap hybridizations in which the reference
#' pool "MRP" was labeled with Cy5 and the patient RNA with Cy3. See
#' [buyseRGcy3] for the swapped hybridizations.
#'
#' @format
#' An `RGList` (see [limma::RGList-class]) with 1900 microarray features and
#' 307 arrays, named `BC.<sample>`. Components:
#'
#' - `R`, `Rb`: raw median foreground and background intensities of the red
#'   channel;
#' - `G`, `Gb`: raw median foreground and background intensities of the
#'   green channel;
#' - `logRatio`, `logRatioError`: the log ratio between the red and green
#'   channels and its error, as reported in the raw Feature Extraction
#'   files (stored as plain list components, not in `other`);
#' - `targets`: a `data.frame` with one row per array combining the SDRF
#'   rows of the two channels: patient characteristics (age, tumor size and
#'   grade, ER status, MammaPrint, NPI, St Gallen and Adjuvant! Online risk
#'   categories, providing center), the `Cy5`/`Cy3` sample assignment, and
#'   the curated end points `OS`/`OSevent`/`TenYearSurv` (overall survival,
#'   years), `DFS`/`DFSevent`/`FiveYearDiseaseFree` (disease-free survival),
#'   `TTM`/`TTMevent`/`FiveYearRecurrence` (time to distant metastasis) and
#'   `toExclude` (patients with unknown ER status, excluded in the original
#'   analysis);
#' - `genes`: a `data.frame` with the `A-MEXP-318` array design annotation
#'   (`Reporter.Name`, `Comment.AEReporterName`, database entries, control
#'   type, grid position) plus `genes231` and `genes70` (logical membership
#'   in the 231-gene and 70-gene prognostic lists) and `gns231Cors` (the
#'   original van 't Veer correlation with outcome, where available);
#' - `source`: `"generic"`.
#'
#' @source ArrayExpress/BioStudies accession E-TABM-77,
#'   <https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-TABM-77>;
#'   raw files archived on Zenodo, \doi{[ZENODO_DOI]} (see
#'   [fetchMammaPrintRaw()]).
#' @references
#' Buyse M, Loi S, van 't Veer L, et al. Validation and clinical utility of
#' a 70-gene prognostic signature for women with node-negative breast
#' cancer. *J Natl Cancer Inst* 2006, 98(17):1183-1192.
#' \doi{10.1093/jnci/djj329}, <https://pubmed.ncbi.nlm.nih.gov/16954471/>.
#' @seealso [buyseRGcy3], [glasRGcy5], [seventyGeneSignature],
#'   [limma::RGList-class]
#' @examples
#' library(limma)
#' class(buyseRGcy5)
#' dim(buyseRGcy5)
#' head(buyseRGcy5$targets, n = 5)
#' head(buyseRGcy5$genes, n = 5)
#' table(
#'   buyseRGcy5$targets$FiveYearRecurrence,
#'   buyseRGcy5$targets$Characteristics.BioSourceProvider
#' )
"buyseRGcy5"

#' Buyse cohort (E-TABM-77): hybridizations with the reference RNA labeled with Cy3
#'
#' @description
#' A `limma` `RGList` with the raw two-color intensities for the 307 breast
#' cancer patients of the Buyse et al. (2006) TRANSBIG validation study,
#' restricted to the set of dye-swap hybridizations in which the reference
#' pool "MRP" was labeled with Cy3 and the patient RNA with Cy5. See
#' [buyseRGcy5] for the swapped hybridizations.
#'
#' @format
#' An `RGList` (see [limma::RGList-class]) with 1900 microarray features and
#' 307 arrays, named `BC.<sample>`. Components are the same as in
#' [buyseRGcy5]:
#'
#' - `R`, `Rb`, `G`, `Gb`: raw median foreground and background intensities
#'   of the red and green channels;
#' - `logRatio`, `logRatioError`: the log ratio between the red and green
#'   channels and its error, as reported in the raw Feature Extraction
#'   files (stored as plain list components, not in `other`);
#' - `targets`: patient characteristics, the `Cy5`/`Cy3` sample assignment
#'   and the curated end points `OS`, `OSevent`, `TenYearSurv`, `DFS`,
#'   `DFSevent`, `FiveYearDiseaseFree`, `TTM`, `TTMevent`,
#'   `FiveYearRecurrence` and `toExclude`;
#' - `genes`: the `A-MEXP-318` annotation plus `genes231`, `genes70` and
#'   `gns231Cors`;
#' - `source`: `"generic"`.
#'
#' @inherit buyseRGcy5 source references
#' @seealso [buyseRGcy5], [glasRGcy3], [seventyGeneSignature],
#'   [limma::RGList-class]
#' @examples
#' library(limma)
#' class(buyseRGcy3)
#' dim(buyseRGcy3)
#' head(buyseRGcy3$targets, n = 5)
#' ## same patients, in the same order, as buyseRGcy5
#' identical(colnames(buyseRGcy3), colnames(buyseRGcy5))
"buyseRGcy3"

#' The 231-gene prognostic reporter list and the 70-gene MammaPrint signature
#'
#' @description
#' Table S2 of van 't Veer et al. (2002): the 231 reporters of the Agilent
#' 24k array whose expression correlated with distant metastasis within five
#' years in the 78-patient training set, parsed from the supplementary
#' spreadsheet `415530a-s9.xls`. Following the supplementary methods of the
#' original publication, the optimal 70-gene signature consists of the 70
#' reporters with the highest absolute correlation; they are flagged in the
#' `signature70` column. Reporter identifiers (accession numbers) and gene
#' symbols are the ones used to map the features of the 1.9k MammaPrint
#' array (`genes231` / `genes70` columns of the `genes` component of the
#' `RGList` data sets).
#'
#' @format
#' A `data.frame` with 231 rows, ordered by decreasing absolute
#' correlation, and 5 columns:
#'
#' - `accession`: reporter identifier (GenBank/RefSeq accession or Rosetta
#'   contig name);
#' - `correlation`: correlation coefficient between the reporter's
#'   expression and the prognosis group in the training set;
#' - `gene.name`: gene symbol (`NA` for anonymous ESTs/contigs);
#' - `description`: gene description;
#' - `signature70`: `TRUE` for the 70 reporters forming the MammaPrint
#'   signature.
#'
#' @source Supplementary Information of van 't Veer et al. (2002), file
#'   `415530a-s9.xls` (Table S2); the original Nature URL is no longer
#'   served, a copy is archived on Zenodo, \doi{[ZENODO_DOI]} (see
#'   [fetchMammaPrintRaw()]).
#' @references
#' van 't Veer LJ, Dai H, van de Vijver MJ, et al. Gene expression profiling
#' predicts clinical outcome of breast cancer. *Nature* 2002, 415:530-536.
#' \doi{10.1038/415530a}.
#' @seealso [glasRGcy5], [buyseRGcy5]
#' @examples
#' head(seventyGeneSignature)
#' table(seventyGeneSignature$signature70)
#' ## features of the MammaPrint array mapped to the 70-gene signature
#' sum(glasRGcy5$genes$genes70)
"seventyGeneSignature"
