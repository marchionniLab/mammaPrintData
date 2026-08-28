# Raw microarray data for the mammaPrintData Bioconductor package

This deposit archives the source files from which the processed data sets
of the Bioconductor experiment-data package **mammaPrintData**
(<https://bioconductor.org/packages/mammaPrintData>,
<https://github.com/marchionniLab/mammaPrintData>) are generated, together
with a copy of the processed objects themselves. The package curates the
two breast cancer cohorts used to implement and validate the MammaPrint
70-gene prognostic signature.

## Files

| File | Content |
|------|---------|
| `E-TABM-115_raw.tar.gz` | ArrayExpress accession **E-TABM-115**, the Glas et al. (2006) cohort (162 patients): `E-TABM-115.sdrf.txt.gz` (sample and data relationship table), `A-MEXP-318.adf.txt.gz` (array design) and 324 gzipped Agilent Feature Extraction raw data files (`US*.txt.gz`), one per hybridization. |
| `E-TABM-77_raw.tar.gz` | ArrayExpress accession **E-TABM-77**, the Buyse et al. (2006) TRANSBIG validation cohort (307 patients): `E-TABM-77.sdrf.txt.gz`, `A-MEXP-318.adf.txt.gz` and 614 gzipped raw data files. |
| `415530a-s9.xls` | Supplementary Table S2 of van 't Veer et al. (2002): the 231 prognostic reporters, from which the 70-gene signature is derived (the original `nature.com` URL is no longer served). |
| `glasRGcy5.rda`, `glasRGcy3.rda` | Processed `limma` `RGList` objects for the Glas cohort (one per dye orientation), as shipped in `data/` of the package. |
| `buyseRGcy5.rda`, `buyseRGcy3.rda` | Processed `RGList` objects for the Buyse cohort. |
| `seventyGeneSignature.rda` | Processed `data.frame` with the 231 reporters and the 70-gene signature flag. |
| `MD5SUMS`, `SHA256SUMS` | Checksums of the files above. |

The tarballs contain the files exactly as they were extracted from the
ArrayExpress bundles `E-TABM-115.raw.1.zip` and `E-TABM-77.raw.1.zip` in
2013 and stored in the package sources until version 1.49.1. Both series
were generated on the custom Agilent 1.9k MammaPrint array, array design
**A-MEXP-318** (Agendia). The individual files are also served by EBI
BioStudies (<https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-TABM-115>,
<https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-TABM-77>); the
bundled zip archives are no longer available there.

The processed `.rda` files were produced from the raw files with the
scripts in the `data-raw/` directory of the package sources; the
`fetchMammaPrintRaw()` function of the package downloads the raw files
from this record.

## References

- Glas AM, Floore A, Delahaye LJ, et al. Converting a breast cancer
  microarray signature into a high-throughput diagnostic test.
  *BMC Genomics* 2006, 7:278. doi:10.1186/1471-2164-7-278
- Buyse M, Loi S, van 't Veer L, et al. Validation and clinical utility of a
  70-gene prognostic signature for women with node-negative breast cancer.
  *J Natl Cancer Inst* 2006, 98(17):1183-1192. doi:10.1093/jnci/djj329
- van 't Veer LJ, Dai H, van de Vijver MJ, et al. Gene expression profiling
  predicts clinical outcome of breast cancer. *Nature* 2002, 415:530-536.
  doi:10.1038/415530a
- Brazma A, et al. ArrayExpress: a public repository for microarray gene
  expression data at the EBI. *Nucleic Acids Res* 2003, 31:68-71.
