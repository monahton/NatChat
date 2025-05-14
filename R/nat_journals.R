#' @title List Available Nature Journals and Their Slugs
#'
#' @description
#' This function returns a data frame of *Nature* journals supported by the `Natchat` package,
#' including their full names and URL slugs (used in links or programmatic access). Optionally,
#' users can provide a journal name to filter and display only the matching journal and its slug.
#'
#' @usage
#' nat_journals(journal = NULL)
#'
#' @param journal Optional character string. The full name of a Nature journal (case-insensitive)
#' to filter the list. If `NULL` (default), returns the full table of available journals and slugs.
#'
#' @return A tibble with two columns:
#' \describe{
#'   \item{journal}{The full name of the journal}
#'   \item{slug}{The short URL identifier (slug) used in Nature journal web addresses}
#' }
#'
#' @details
#' - The `slug` corresponds to the subdirectory used in Nature URLs (e.g., `"https://www.nature.com/nbt/"` for *Nature Biotechnology*).
#' - Journal name matching is case-insensitive and supports exact matches only (no partial or fuzzy matching).
#'
#' @examples
#' nat_journals()
#' nat_journals("Nature Medicine")
#' nat_journals("nature biotechnology")
#'
#' @importFrom tibble tibble
#' @export

nat_journals <- function(journal = NULL) {
  journal_df <- tibble::tibble(
    journal = c(
      "Nature",
      "Nature Aging",
      "Nature Astronomy",
      "Nature Biomedical Engineering",
      "Nature Biotechnology",
      "Nature Cancer",
      "Nature Cardiovascular Research",
      "Nature Catalysis",
      "Nature Cell Biology",
      "Nature Chemical Biology",
      "Nature Chemical Engineering",
      "Nature Chemistry",
      "Nature Cities",
      "Nature Climate Change",
      "Nature Communications",
      "Nature Computational Science",
      "Nature Ecology & Evolution",
      "Nature Electronics",
      "Nature Energy",
      "Nature Food",
      "Nature Genetics",
      "Nature Geoscience",
      "Nature Human Behaviour",
      "Nature Immunology",
      "Nature Machine Intelligence",
      "Nature Materials",
      "Nature Medicine",
      "Nature Mental Health",
      "Nature Metabolism",
      "Nature Methods",
      "Nature Microbiology",
      "Nature Nanotechnology",
      "Nature Neuroscience",
      "Nature Photonics",
      "Nature Physics",
      "Nature Plants",
      "Nature Protocols",
      "Nature Reviews Biodiversity",
      "Nature Reviews Bioengineering",
      "Nature Reviews Cancer",
      "Nature Reviews Cardiology",
      "Nature Reviews Chemistry",
      "Nature Reviews Clean Technology",
      "Nature Reviews Clinical Oncology",
      "Nature Reviews Disease Primers",
      "Nature Reviews Drug Discovery",
      "Nature Reviews Earth & Environment",
      "Nature Reviews Electrical Engineering",
      "Nature Reviews Endocrinology",
      "Nature Reviews Gastroenterology & Hepatology",
      "Nature Reviews Genetics",
      "Nature Reviews Immunology",
      "Nature Reviews Materials",
      "Nature Reviews Methods Primers",
      "Nature Reviews Microbiology",
      "Nature Reviews Molecular Cell Biology",
      "Nature Reviews Nephrology",
      "Nature Reviews Neurology",
      "Nature Reviews Neuroscience",
      "Nature Reviews Physics",
      "Nature Reviews Psychology",
      "Nature Reviews Rheumatology",
      "Nature Reviews Urology",
      "Nature Sensors",
      "Nature Structural & Molecular Biology",
      "Nature Sustainability",
      "Nature Synthesis",
      "Nature Water"
    ),
    slug = c(
      "nature",
      "nataging",
      "natastron",
      "natbiomedeng",
      "nbt",
      "natcancer",
      "natcardiovascres",
      "natcatal",
      "ncb",
      "nchembio",
      "natchemeng",
      "nchem",
      "natcities",
      "nclimate",
      "ncomms",
      "natcomputsci",
      "natecolevol",
      "natelectron",
      "nenergy",
      "natfood",
      "ng",
      "ngeo",
      "nathumbehav",
      "nri",
      "natmachintell",
      "nmat",
      "nm",
      "natmentalhealth",
      "natmetab",
      "nmeth",
      "nmicrobiol",
      "nnano",
      "neuro",
      "nphoton",
      "nphys",
      "nplants",
      "nprot",
      "nrbd",
      "natrevbioeng",
      "nrc",
      "nrcardio",
      "natrevchem",
      "nrct",
      "nrclinonc",
      "nrdp",
      "nrd",
      "natrevearthenviron",
      "natrevelectreng",
      "nrendo",
      "nrgastro",
      "nrg",
      "nri",
      "natrevmats",
      "nrmp",
      "nrmicro",
      "nrmcb",
      "nrneph",
      "nrneurol",
      "nrn",
      "natrevphys",
      "nrpsychol",
      "nrrheum",
      "nrurol",
      "natsensors",
      "nsmb",
      "natsustain",
      "natsynth",
      "natwater"
    )
  )
  if (!is.null(journal)) {
    journal_lower <- tolower(journal)
    journal_df <- journal_df[tolower(journal_df$journal) == journal_lower, ]
  }
  return(journal_df)
}
