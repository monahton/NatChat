#' @title Retrieve Articles from a Nature Journal's Current Issue
#'
#' @description This function scrapes articles from the current issue of a specified Nature journal,
#' extracting article titles, URLs, and abstracts with robust fallback handling.
#'
#' @usage
#' get_articles(journal, article_selector = ".c-card.c-card--flush",
#'              title_selector = "h3 a", url_selector = "h3 a",
#'              abstract_selector = ".c-card__summary", verbose = FALSE)
#'
#' @param journal Character string. The full name of the Nature journal (e.g., "Nature Biotechnology", "Nature Medicine").
#' @param article_selector Character string. CSS selector for locating articles on the journal's webpage. Default is ".c-card.c-card--flush".
#' @param title_selector Character string. CSS selector for extracting article titles. Default is "h3 a".
#' @param url_selector Character string. CSS selector for extracting article URLs. Default is "h3 a".
#' @param abstract_selector Character string. CSS selector for extracting article abstracts. Default is ".c-card__summary".
#' @param verbose Logical. If TRUE, prints messages about progress and internal steps. Default is FALSE.
#'
#' @return A tibble with columns: `title`, `url`, `abstract`, and `source`. If no articles are found, returns an empty tibble.
#'
#' @details
#' The journal argument is matched (case-insensitively) against available entries from `nat_journals()`.
#' If not found, an informative error is thrown. Abstracts that are missing are replaced with "Abstract not available".
#' If titles, URLs, and abstracts differ in length, they are truncated to the shortest length with a warning.
#'
#' @examples
#' get_articles("Nature Biotechnology")
#' get_articles("Nature Reviews Genetics", verbose = TRUE)
#'
#' @importFrom xml2 read_html url_absolute
#' @importFrom rvest html_nodes html_node html_text html_attr
#' @importFrom dplyr mutate distinct
#' @importFrom tibble tibble
#' @export
get_articles <- function(journal,
                         article_selector = ".c-card.c-card--flush",
                         title_selector = "h3 a",
                         url_selector = "h3 a",
                         abstract_selector = ".c-card__summary",
                         verbose = FALSE) {
  # Empty tibble template
  empty_tibble <- tibble::tibble(title = character(), url = character(), abstract = character(), source = character())

  # Match journal
  all_journals <- nat_journals()
  slug_row <- all_journals[tolower(all_journals$journal) == tolower(journal), ]
  if (nrow(slug_row) == 0) {
    stop(sprintf("The journal name '%s' is not supported.\nUse `nat_journals()` to see supported journals.", journal))
  }

  slug <- slug_row$slug
  base_url <- sprintf("https://www.nature.com/%s/current-issue", slug)

  if (verbose) message("Accessing URL: ", base_url)

  # Read page
  page <- tryCatch(xml2::read_html(base_url), error = function(e) NULL)
  if (is.null(page)) {
    message("Unable to retrieve current issue for ", journal, ". The page may be unavailable.")
    return(empty_tibble)
  }

  result <- tryCatch({
    if (verbose) message("Extracting articles from ", base_url)

    articles <- rvest::html_nodes(page, article_selector)
    if (length(articles) == 0) {
      warning("No articles found on page for ", journal)
      return(empty_tibble)
    }

    titles <- rvest::html_node(articles, title_selector) |> rvest::html_text(trim = TRUE)
    urls <- rvest::html_node(articles, url_selector) |> rvest::html_attr("href") |> xml2::url_absolute(base_url)
    abstracts <- rvest::html_node(articles, abstract_selector) |> rvest::html_text(trim = TRUE)
    abstracts[is.na(abstracts) | abstracts == ""] <- "Abstract not available"

    min_len <- min(length(titles), length(urls), length(abstracts))
    if (length(titles) != length(urls) || length(titles) != length(abstracts)) {
      warning(sprintf("Mismatch in lengths: titles (%d), urls (%d), abstracts (%d). Trimming to minimum (%d).",
                      length(titles), length(urls), length(abstracts), min_len))
      titles <- titles[seq_len(min_len)]
      urls <- urls[seq_len(min_len)]
      abstracts <- abstracts[seq_len(min_len)]
    }

    papers <- tibble::tibble(
      title = titles,
      url = urls,
      abstract = abstracts,
      source = journal
    ) |>
      dplyr::mutate(abstract = gsub("\\s+", " ", abstract)) |>
      dplyr::distinct(title, .keep_all = TRUE)

    if (verbose) message(nrow(papers), " articles successfully extracted.")

    papers

  }, error = function(e) {
    message("Error scraping ", journal, ": ", e$message)
    return(empty_tibble)
  })

  class(result) <- c("nature_journal", class(result))
  return(result)
}
