#' @title Save Report as CSV and HTML
#'
#' @description
#' Save a data frame of article metadata as both a CSV file and an HTML file with a markdown-styled table.
#' Options are provided to control file format outputs and verbosity.
#'
#' @usage
#' save_report(input, filename, save_csv, save_html, title, cols, width, verbose, outdir)
#'
#' @param input A data frame containing article data (e.g., "title", "summary", "url").
#' @param filename A character string specifying the base filename.
#' @param save_csv Logical. Save output as a CSV file? Default is TRUE.
#' @param save_html Logical. Save output as an HTML file? Default is TRUE.
#' @param title A character string specifying the HTML page title. Default is "Article Summary Report".
#' @param cols A character vector of column names to include in the output. Default is c("title", "summary").
#' @param width A numeric vector of column widths for the HTML table. Default is c(1, 3).
#' @param verbose Logical. Should messages be printed? Default is TRUE.
#' @param outdir A character string specifying the directory to save files. Default is current working directory ".".
#'
#' @return
#' Files are written to disk in the specified formats. The function returns (invisibly) a list of saved file paths.
#'
#' @details
#' A timestamp is appended to the base filename to uniquely identify each output.
#' If both save_csv and save_html are FALSE, no files are saved and a message is issued (if verbose = TRUE).
#'
#' @examples
#' \dontrun{
#' papers <- get_articles(journal = "Nature Medicine")
#' papers_with_summary <- add_summary(papers)
#' save_report(papers_with_summary, save_csv = TRUE, save_html = TRUE)
#' }
#'
#' @importFrom dplyr select all_of
#' @importFrom readr write_csv
#' @importFrom tinytable save_tt
#' @importFrom tools file_path_sans_ext
#' @export
#' @keywords markdown, HTML, CSV

save_report <- function(input, filename = "natchat_summary",
                        save_csv = TRUE,
                        save_html = TRUE,
                        title = "Article Summary Report",
                        cols = c("title", "summary"),
                        width = c(1, 3),
                        verbose = TRUE,
                        outdir = ".") {

  if (!inherits(input, "data.frame")) stop("input must be a data frame.")

  missing_cols <- setdiff(cols, names(input))
  if (length(missing_cols) > 0) {
    stop("The following columns are missing in input: ", paste(missing_cols, collapse = ", "))
  }

  if (!save_csv && !save_html) {
    if (verbose) message("No output saved: both save_csv and save_html are FALSE.")
    return(invisible(NULL))
  }

  filename <- tools::file_path_sans_ext(filename)
  timestamp <- format(Sys.time(), "%Y%m%d")
  base_filename <- paste0(filename, "_", timestamp)
  csv_file <- file.path(outdir, paste0(base_filename, ".csv"))
  html_file <- file.path(outdir, paste0(base_filename, ".html"))

  now <- Sys.time()
  date_str <- format(now, "%B %d, %Y")
  time_str <- format(now, "%H:%M:%S")
  journal_name <- if ("source" %in% names(input)) paste(unique(input$source), collapse = ", ") else "Unknown"

  saved_files <- list()

  if (save_csv) {
    readr::write_csv(input |> dplyr::select(dplyr::all_of(cols)), csv_file)
    if (verbose) message("CSV saved to: ", csv_file)
    saved_files$csv <- csv_file
  }

  if (save_html) {
    tt_obj <- tt_article(input, cols = cols, width = width)

    html_header <- sprintf(
      "<html>
  <head>
    <meta charset='UTF-8'>
    <title>%s</title>
    <style>
      body {
        font-family: 'Segoe UI', 'Helvetica Neue', sans-serif;
        padding: 40px;
        background-color: #fdfdfd;
        color: #333;
      }
      h1 {
        text-align: center;
        margin-bottom: 5px;
        font-size: 32px;
        color: #2c3e50;
      }
      p.date {
        text-align: center;
        font-size: 16px;
        color: #666;
        margin-bottom: 30px;
        font-weight: bold;
      }
      h2 {
        font-size: 22px;
        margin-top: 40px;
        border-bottom: 2px solid #eee;
        padding-bottom: 5px;
        color: #34495e;
      }
      ul {
        margin-top: 10px;
        padding-left: 20px;
      }
      ul li {
        font-size: 16px;
        margin-bottom: 6px;
      }
      .spacer {
        margin-top: 50px;
      }
      table {
        width: 100%%;
        border-collapse: collapse;
        margin-top: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        background-color: #fff;
      }
      th, td {
        border: 1px solid #ddd;
        padding: 12px 15px;
        text-align: left;
        font-size: 15px;
      }
      th {
        background-color: #3498db;
        color: white;
        font-weight: bold;
      }
      tr:nth-child(even) {
        background-color: #f9f9f9;
      }
      tr:hover {
        background-color: #f1f1f1;
      }
    </style>
  </head>
  <body>
    <h1>%s</h1>
    <p class='date'>%s</p>
    <h2>Report Information</h2>
    <ul>
      <li><strong>Generated by:</strong> NatChat v1.1.0</li>
      <li><strong>Date:</strong> %s</li>
      <li><strong>Time:</strong> %s</li>
      <li><strong>Journal:</strong> %s</li>
      <li><strong>Model:</strong> llama3.2</li>
    </ul>
    <div class='spacer'></div>
    <h2>Articles Summary</h2>",
      title, title, date_str, date_str, time_str, journal_name
    )

    html_footer <- "
    <div class='spacer'></div>
    <hr style='margin-top: 60px;'>
    <p style='text-align: center; font-size: 14px; color: #aaa;'>
      Report generated by <strong>NatChat</strong> - <em>Powered by local LLMs</em>
    </p>
  </body>
</html>"

    tinytable::save_tt(tt_obj, output = html_file, overwrite = TRUE)
    html_content <- readLines(html_file)
    writeLines(c(html_header, html_content[-(1:6)], html_footer), html_file)

    if (verbose) message("HTML saved to: ", html_file)
    saved_files$html <- html_file
  }

  invisible(saved_files)
}



#' @title Summarize a Nature Journal Issue
#'
#' @description
#' Retrieve and summarize abstracts from the current issue of a selected Nature Portfolio journal using a local LLM and save the output as CSV and/or HTML.
#' Optionally filter the articles by a set of whitelist terms.
#'
#' @usage
#' summarize_journal(journal, filename, outdir, model,save_csv,save_html,verbose, whitelist)
#'
#' @param journal A character string indicating the name of the supported Nature journal (e.g., "Nature Biotechnology").
#' @param filename A character string specifying the base filename for saving the report. Default is "natchat_summary".
#' @param outdir A character string specifying the directory to save output files. Default is current working directory ".".
#' @param model A character string specifying the local Ollama model to use for summarization (e.g., "llama3:instruct").
#' @param save_csv Logical. Save the results as a CSV file? Default is TRUE.
#' @param save_html Logical. Save the results as an HTML file? Default is TRUE.
#' @param verbose Logical. Should informative messages be printed to the console? Default is TRUE.
#' @param whitelist Optional character vector of terms used to filter articles based on title and abstract. Default is NULL (no filtering).
#'
#' @return
#' Invisibly returns a list of file paths (if saved). Generates summarized article metadata and optionally saves it to disk.
#'
#' @details
#' This function is a convenience wrapper around `get_articles()`, `add_prompt()`, `add_summary()`, and `save_report()`.
#' It scrapes the current issue, optionally filters articles using a whitelist of terms, summarizes abstracts using a local LLM, and exports the result.
#'
#' @examples
#' \dontrun{
#' summarize_journal(
#'   journal = "Nature Medicine",
#'   model = "llama3",
#'   whitelist = c("CRISPR", "gene therapy"),
#'   save_csv = TRUE,
#'   save_html = TRUE
#' )
#' }
#'
#' @export

summarize_journal <- function(journal,
                              filename = "natchat_summary",
                              outdir = ".",
                              model = "llama3.1",
                              save_csv = TRUE,
                              save_html = TRUE,
                              verbose = TRUE,
                              whitelist = NULL) {

  if (verbose) message("Scraping articles from journal: ", journal)
  df <- get_articles(journal, verbose = FALSE)

  if (nrow(df) == 0) {
    stop("No articles found. Please check available journal names by running `nat_journals()` function or try again later.")
  }

  if (!is.null(whitelist)) {
    if (verbose) message("Filtering articles using whitelist terms...")
    df <- filter_articles(df, whitelist_terms = whitelist)
    if (nrow(df) == 0) {
      stop("No articles matched the whitelist terms. Try different keywords.")
    }
  }

  if (verbose) message("Building prompts...")
  df <- add_prompt(df)

  if (verbose) message("Generating summaries using model: ", model)
  df <- add_summary(df, model = model)

  if (verbose) message("Saving report...")
  paths <- save_report(
    input = df,
    filename = filename,
    save_csv = save_csv,
    save_html = save_html,
    verbose = verbose,
    outdir = outdir
  )

  invisible(paths)
}
