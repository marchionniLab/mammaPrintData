# mammaPrintData modernization — Phase 1 implementation plan

Plan for Claude Code. Execute tasks in order on the `devel` branch of the
maintainer's existing clone. Remote layout (already configured, do not
change): `bioconductor` = git@git.bioconductor.org:packages/mammaPrintData
(authoritative, coordinated pushes only), `github` =
https://github.com/marchionniLab/mammaPrintData.git (mirror, HTTPS via gh
credential helper), `remote.pushDefault` = github. Do NOT push to any
remote.
Do NOT start the vignette renovation (that is Phase 2); only apply the
minimal vignette shim in Task 7 so the package keeps building.

## Context (verified 2026-08-26)

Bioconductor requires removal of files >100 MB from the git tree before the
GitHub migration (deadline end of August 2026). Independently of that, the
maintainer wants to modernize the package: ship ONLY processed data to end
users, move all raw data to Zenodo (with ArrayExpress/BioStudies as an
alternative source), adopt `usethis::use_data()` / `use_data_raw()`
conventions per <https://r-pkgs.org/data.html>, lazy-load data, and document
everything with roxygen2 in Markdown mode (no LaTeX in docs).

Current package state (pure data package, Bioc devel version 1.49.0):

- NO `R/` directory. `NAMESPACE` is a single `exportPattern(".")`.
- `data/glasRG.rda` (3.7 MB) holds TWO objects: `glasRGcy5`, `glasRGcy3`.
  `data/buyseRG.rda` (6.9 MB) holds TWO objects: `buyseRGcy5`, `buyseRGcy3`.
  All four are `limma` `RGList` objects. `data/datalist` maps them.
- `inst/extdata/ETABM77/` (135 MB, 616 files) and `inst/extdata/ETABM115/`
  (71 MB, 327 files): extracted ArrayExpress raw per-array `.txt.gz` files
  plus `*.sdrf.txt.gz` and `A-MEXP-318.adf.txt.gz`.
- `inst/extdata/seventyGene/415530a-s9.xls` (88 KB): van 't Veer Nature
  supplement with the 70-gene MammaPrint signature. Its original
  `nature.com` URL is dead.
- `vignettes/mammaPrintData.Rnw`: Sweave/LaTeX. Contains BOTH the shown-but-
  not-executed download code (`ArrayExpress::getAE`) AND executed chunks
  that read `inst/extdata` via `system.file()` at build time. The full
  raw-to-RGList processing logic lives ONLY in this vignette.
- Legacy/stray files: `INDEX`, `external_data_store.txt`, `renv/`,
  `renv.lock`, `.Rprofile` (renv activation), `mammaPrintData.Rproj`.
- `DESCRIPTION`: `LazyLoad: yes` (legacy), no `LazyData`, maintainer still
  lists the previous maintainer, `Suggests: Biobase, readxl, limma`.
- Git history: the two oversized blobs (`E-TABM-77.raw.1.zip` 133 MB,
  `E-TABM-115.raw.1.zip` 70 MB) exist ONLY in the `RELEASE_3_5` lineage.
  Their purge is handled by a separate script
  (`clean_mammaPrintData_history.sh`) and a coordinated force push — NOT
  part of this plan. Nothing in this plan rewrites history.
- GitHub mirror `marchionniLab/mammaPrintData` exists (empty or
  devel-only). Description and topics are set via `gh repo edit`. Default
  branch: devel. GitHub is a mirror only; git.bioconductor.org remains
  authoritative.
- Upstream raw data availability: BioStudies serves the per-file tree at
  `https://ftp.ebi.ac.uk/biostudies/fire/E-TABM-/077/E-TABM-77/Files/` and
  `https://ftp.ebi.ac.uk/biostudies/fire/E-TABM-/115/E-TABM-115/Files/`
  (verified HTTP 200 on sdrf files). The bundled `.raw.1.zip` archives are
  NO LONGER served anywhere public — Zenodo will be their only home.

## Placeholders (human fills in later; use verbatim in code/docs)

| Placeholder            | Meaning                                    |
|------------------------|--------------------------------------------|
| `[MAINTAINER_NAME]`    | New maintainer's full name                 |
| `[MAINTAINER_EMAIL]`   | New maintainer's email                     |
| `[ZENODO_DOI]`         | DOI of the Zenodo deposit (e.g. 10.5281/…) |
| `[ZENODO_RECORD_ID]`   | Numeric Zenodo record id for file URLs     |

## Resolved design decisions

1. **One rda per object** via `usethis::use_data(..., compress = "xz",
   overwrite = TRUE)`: `glasRGcy5.rda`, `glasRGcy3.rda`, `buyseRGcy5.rda`,
   `buyseRGcy3.rda`. Delete `data/datalist` (unneeded with LazyData).
   Backward-compat note: `data(glasRG)` / `data(buyseRG)` will stop
   working; with lazy loading users access objects directly by name, and
   `data(glasRGcy5)` etc. still works. Record this in NEWS.md and the
   package-level doc.
2. **New processed dataset**: `seventyGeneSignature` — a data.frame parsed
   from `415530a-s9.xls` (port the readxl parsing chunk from the vignette).
   This turns the raw xls into a proper processed object.
3. **Exported fetcher for raw data**: one function
   `fetchMammaPrintRaw(accession = c("E-TABM-77", "E-TABM-115"),
   source = c("zenodo", "biostudies"), cache = BiocFileCache::BiocFileCache())`
   returning local cached paths via BiocFileCache. Zenodo is the primary
   source (single archive per accession); BioStudies is the per-file
   fallback. This is the end-user-facing "option to download from either
   source". `data-raw/` scripts reuse it.
4. **Dependencies**: `Imports: BiocFileCache, utils`. `Suggests: limma
   (RGList class docs/examples), readxl, BiocStyle` (BiocStyle only when
   Phase 2 starts — omit for now). Drop `Biobase` from Suggests (unused
   after extdata removal) unless grep shows otherwise. `usethis` is used
   interactively only — not a dependency.
5. **data-raw/ location**: the Bioconductor contribution guide lists
   `inst/scripts/` as the preferred home for data-generation code, with a
   `data-raw/` directory as an accepted alternative. This project uses
   `data-raw/` (maintainer's choice, r-pkgs.org convention). If a
   Bioconductor reviewer ever objects, the scripts can be moved verbatim.
6. **Roxygen**: `Roxygen: list(markdown = TRUE)` in DESCRIPTION; delete all
   hand-written `man/*.Rd`; NAMESPACE becomes roxygen-generated. No LaTeX
   markup in any roxygen text.

## Tasks

### Task 1 — Archive the raw data BEFORE deleting it

The repo working tree is currently the only convenient complete copy of the
original ArrayExpress files. Create the Zenodo upload artifacts first:

```bash
mkdir -p zenodo-deposit
tar -C inst/extdata -czf zenodo-deposit/E-TABM-77_raw.tar.gz ETABM77
tar -C inst/extdata -czf zenodo-deposit/E-TABM-115_raw.tar.gz ETABM115
cp inst/extdata/seventyGene/415530a-s9.xls zenodo-deposit/
cd zenodo-deposit && md5sum * > MD5SUMS && sha256sum E-TABM* 415530a-s9.xls > SHA256SUMS && cd ..
echo "zenodo-deposit" >> .gitignore
```

Also write `zenodo-deposit/README.md` describing provenance: files obtained
from ArrayExpress accessions E-TABM-77 (Glas 2006, BMC Genomics 7:278) and
E-TABM-115 (Buyse 2006, JNCI 98(17):1183), array design A-MEXP-318, plus
the van 't Veer 2002 Nature supplementary table `415530a-s9.xls` (70-gene
signature). The tarballs are NOT committed to git; the human uploads them
to Zenodo manually (see "Human follow-ups").

### Task 2 — Scaffolding

- `usethis::use_data_raw()` conventions by hand (do not rely on interactive
  usethis calls): create `data-raw/` and add `^data-raw$` to `.Rbuildignore`.
- Create `R/` directory.
- Add to `.Rbuildignore`: `^data-raw$`, `^zenodo-deposit$`,
  `^.*\.Rproj$`, `^\.Rproj\.user$`, `^renv$`, `^renv\.lock$`,
  `^\.Rprofile$`, `^NEWS\.md$` is NOT ignored (Bioconductor renders it).

### Task 3 — Port processing code from the vignette into data-raw/

Source of truth: chunks in `vignettes/mammaPrintData.Rnw`. Grep anchors:
`read.maimages`, `system.file("extdata`, `415530a-s9.xls`, `readxl`,
`sdrf`. Create:

- `data-raw/seventyGeneSignature.R` — port the xls parsing chunk
  (~line 220-260 of the Rnw); read the xls from
  `fetchMammaPrintRaw` output (Zenodo) with a dev-time fallback to a local
  `zenodo-deposit/415530a-s9.xls` copy; end with
  `usethis::use_data(seventyGeneSignature, compress = "xz", overwrite = TRUE)`.
- `data-raw/glasRG.R` — port the E-TABM-77 processing chunks (sdrf parsing,
  dye-swap splitting into cy5/cy3 target sets, `limma::read.maimages`,
  annotation attachment). End with
  `usethis::use_data(glasRGcy5, glasRGcy3, compress = "xz", overwrite = TRUE)`.
- `data-raw/buyseRG.R` — same for E-TABM-115 →
  `usethis::use_data(buyseRGcy5, buyseRGcy3, compress = "xz", overwrite = TRUE)`.
- `data-raw/README.md` — one paragraph: what each script does, that raw
  inputs come from Zenodo `[ZENODO_DOI]` or BioStudies, and record
  `sessionInfo()` output from the regeneration run.

**Regression gate (mandatory):** before overwriting `data/`, load the
CURRENT `data/glasRG.rda` and `data/buyseRG.rda` into a separate
environment and verify the regenerated objects satisfy
`all.equal(new, old, check.attributes = FALSE)` and identical `dim()`,
`names()`, and `targets` row order. If porting cannot reproduce the objects
exactly (e.g. an upstream file changed), STOP and report the diff instead
of silently shipping different data. If R or Bioc packages are unavailable
in the execution environment, write the scripts anyway, keep the existing
rda content by re-saving the four objects split from the current combined
files with `save(..., compress = "xz")`, and flag the regression gate as
"not yet executed" in the final report.

### Task 4 — R/ code and roxygen docs (Markdown mode, no LaTeX)

- `R/mammaPrintData-package.R`: package-level doc (`@keywords internal`,
  `"_PACKAGE"` sentinel). Describe both cohorts, cite Glas 2006 and Buyse
  2006 with PubMed URLs, note the raw-data relocation to Zenodo
  `[ZENODO_DOI]` and the `data(glasRG)`→`glasRGcy5` compat change.
- `R/data.R`: one roxygen block per dataset (`glasRGcy5`, `glasRGcy3`,
  `buyseRGcy5`, `buyseRGcy3`, `seventyGeneSignature`). Port the content of
  the existing `man/*.Rd` files (formats, component lists, sources,
  references) into Markdown roxygen (`@format`, `@source`, `@references`,
  itemized lists with `-`, code with backticks). End each block with the
  quoted dataset name, no `@export`.
- `R/fetch-raw.R`: implement and `@export fetchMammaPrintRaw()` as decided
  above. URL table inside:
  - Zenodo: `https://zenodo.org/records/[ZENODO_RECORD_ID]/files/E-TABM-77_raw.tar.gz?download=1` (same pattern for 115 and the xls)
  - BioStudies base: `https://ftp.ebi.ac.uk/biostudies/fire/E-TABM-/077/E-TABM-77/Files/` and `.../115/E-TABM-115/Files/`
  For `source = "biostudies"` fetch the per-file listing lazily (download
  only `sdrf`/`adf` plus files the caller names via a `files` argument);
  document clearly that the complete per-array set is hundreds of files and
  Zenodo is the recommended source. Use `BiocFileCache::bfcrpath()` for all
  downloads. Include `@examples` wrapped in `\dontrun{}`-equivalent
  markdown roxygen (`@examplesIf interactive()`).
- Delete all files in `man/` (roxygen regenerates them), delete `NAMESPACE`
  content and regenerate with `roxygen2::roxygenise()` (or
  `devtools::document()`). If R is unavailable, write the roxygen source
  and leave a hand-written minimal `NAMESPACE`
  (`export(fetchMammaPrintRaw)`, `importFrom` lines) with a TODO to
  regenerate.

### Task 5 — data/ layout

- Replace `data/glasRG.rda` + `data/buyseRG.rda` with the four per-object
  xz-compressed rda files (from Task 3) plus `data/seventyGeneSignature.rda`.
- Delete `data/datalist`.
- Target: every file in `data/` under 5 MB (BiocCheck per-file limit).
  xz recompression of the split objects is expected to get `buyseRGcy5/cy3`
  under the limit; report final sizes.

### Task 6 — DESCRIPTION overhaul

Rewrite DESCRIPTION with these fields (keep `Package`, `Title`,
`Description` meaning; modernize wording):

```
Package: mammaPrintData
Type: Package
Title: Gene Expression Data from the MammaPrint Validation Cohorts of the
    Glas and Buyse Studies
Version: 1.49.2
Authors@R: c(
    person("Luigi", "Marchionni", email = "marchion@gmail.com", role = "aut"),
    person("[MAINTAINER_NAME]", email = "[MAINTAINER_EMAIL]", role = c("cre", "ctb")))
Description: Curated gene expression data from the two breast cancer
    cohorts used to develop and validate the MammaPrint 70-gene prognostic
    signature: the Glas et al. (2006) implementation study
    <doi:10.1186/1471-2164-7-278> and the Buyse et al. (2006) TRANSBIG
    validation study <doi:10.1093/jnci/djj329>. Each cohort was profiled
    on a custom two-color Agilent array (A-MEXP-318) with a dye-swap
    design, and is provided as a pair of limma RGList objects, one per
    dye orientation, with probe annotation and patient-level clinical
    information attached. The 70-gene signature itself is included as a
    processed data set. The original raw files from ArrayExpress
    (E-TABM-77 and E-TABM-115) are archived on Zenodo
    <doi:[ZENODO_DOI]> and can be retrieved with fetchMammaPrintRaw().
License: Artistic-2.0
Encoding: UTF-8
LazyData: true
Depends: R (>= 4.4.0)
Imports: BiocFileCache, utils
Suggests: limma, readxl, testthat (>= 3.0.0)
biocViews: ExperimentData, ExpressionData, CancerData, BreastCancerData,
    MicroarrayData, TwoChannelData
URL: https://github.com/marchionniLab/mammaPrintData, https://doi.org/[ZENODO_DOI]
BugReports: https://github.com/marchionniLab/mammaPrintData/issues
Roxygen: list(markdown = TRUE)
RoxygenNote: <current roxygen2 version>
Config/testthat/edition: 3
```

Remove: `LazyLoad`, `Date`, `Packaged`, old `Author`/`Maintainer` fields
(superseded by `Authors@R`), stale `URL: http://luigimarchionni.org/...`.
Version rationale: last version pushed to Bioconductor is 1.49.0; a local
1.49.1 bump commit already exists on devel, so Phase 1 completes at 1.49.2.
If the local history differs, use (last pushed z) + 2 or simply the next
unused z.
Note: `LazyData: true` triggers a BiocCheck note for ExperimentData
packages historically, but it is required for this design and permitted;
mention in the final report if BiocCheck flags it.

### Task 7 — Repo hygiene + vignette shim (NOT the renovation)

- `git rm -r inst/extdata` (all three subdirectories — raw data now lives
  in the Zenodo deposit prepared in Task 1).
- `git rm -r renv renv.lock .Rprofile INDEX external_data_store.txt data/datalist`
- Keep `mammaPrintData.Rproj` (build-ignored) and `inst/CITATION` (update
  maintainer-related text only if it mentions data location).
- Vignette shim only: in `mammaPrintData.Rnw`, set `eval=FALSE` on every
  chunk that touches `system.file("extdata", ...)` or reads local raw
  files, adding a one-line LaTeX comment
  `% Phase 2 TODO: replace with fetchMammaPrintRaw() + Rmd/Quarto rewrite`.
  Do not otherwise edit the vignette. The package must still build.

### Task 8 — NEWS.md

Create NEWS.md with a `Changes in version 1.49.2` section covering: raw
data relocated to Zenodo/BioStudies with `fetchMammaPrintRaw()`; per-object
lazy-loaded datasets (compat note re `data(glasRG)`); new
`seventyGeneSignature` dataset; roxygen2 documentation; removal of
renv/legacy files; git history cleanup of oversized archives.

### Task 9 — Validation

Run and report results of:

```bash
R CMD build .
R CMD check --no-manual mammaPrintData_1.49.2.tar.gz
Rscript -e 'BiocCheck::BiocCheck("mammaPrintData_1.49.2.tar.gz")'
```

Acceptance: check passes with no ERRORs; document every WARNING/NOTE with
a one-line justification. Expected notes: LazyData on a data package,
possibly vignette eval=FALSE chunks. Tarball size should drop from ~210 MB
to roughly the size of `data/` (~11 MB).

Optionally add `tests/testthat/test-datasets.R` asserting classes
(`RGList`), dims (1900 features; 162 samples Glas-era counts vs 307 Buyse —
verify against regenerated objects, do not hard-code from this plan), and
presence of `targets`/`genes` components.

### Task 10 — Commit structure

Separate commits on `devel`, in order:
1. `Archive raw data for Zenodo deposit (build-ignored)` (Task 1 README +
   ignore entries only; tarballs never committed)
2. `Port raw-data processing from vignette to data-raw/`
3. `Add fetchMammaPrintRaw() and roxygen2 documentation`
4. `Split datasets into per-object lazy-loaded rda files`
5. `Remove bundled raw data, renv, and legacy files; vignette shim`
6. `Modernize DESCRIPTION; add NEWS.md; bump to 1.49.2`

## Human follow-ups (outside Claude Code's scope)

1. Create the Zenodo deposit: upload the four files from `zenodo-deposit/`
   plus README and checksum files; metadata: title "Raw microarray data for
   the mammaPrintData Bioconductor package (ArrayExpress E-TABM-77 and
   E-TABM-115)", link the two papers, license matching ArrayExpress terms.
   Then replace `[ZENODO_DOI]` / `[ZENODO_RECORD_ID]` everywhere
   (`grep -rn "ZENODO"` must come back clean) and re-run Task 9.
2. Fill `[MAINTAINER_NAME]` / `[MAINTAINER_EMAIL]`.
3. Git history purge + coordinated force push of `RELEASE_3_5` per the
   separate `clean_mammaPrintData_history.sh` and the drafted reply email —
   independent of these devel commits and can proceed in parallel.
4. Phase 2 (separate session): vignette renovation (Rmd/Quarto decision),
   using `fetchMammaPrintRaw()` for any raw-data demonstrations.
