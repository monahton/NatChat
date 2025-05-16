#' @title Construct a Text Prompt for Summarizing an Article
#'
#' @description
#' Builds a structured prompt from an article's title and abstract, designed for input to a language model.
#' The prompt emphasizes extracting key findings, methodology, and tone, and is customizable via instructions.
#'
#'
#' @param title Character string. The title of the article.
#' @param abstract Character string. The abstract of the article. If unavailable, include a default message.
#' @param nsentences Integer. The number of sentences required in the summary. Default is 3.
#'                  Must be a positive whole number.
#' @param instructions Character vector. A set of instructions guiding the summarization. Defaults to a structured template emphasizing main findings, methods, novelty, and tone.
#'
#' @return A character string representing a structured prompt for use with a language model summarization tool.
#'
#' @details
#' The generated prompt follows a structured format:
#' - Lists the instructions (customizable via `instructions`).
#' - States the number of summary sentences required (`nsentences`).
#' - Embeds the article title and abstract.
#' - If the abstract is missing or not available, the prompt explicitly states this.
#'
#' The default `instructions` vector can be modified to adapt the tone or focus of the summary, such as prioritizing method, dataset, confidence tone, or accessibility for non-specialists.
#'
#' @examples
#' title <- "Deep Learning for Genomic Data Analysis"
#' abstract <- "This study explores deep learning in diverse tasks highlighting predictive accuracy."
#' prompt <- build_prompt(title, abstract, nsentences = 3)
#' cat(prompt)
#'
#' @export
#' @keywords summarization NLP prompt engineering LLM
build_prompt <- function(
    title,
    abstract,
    nsentences = 3L,
    instructions = c(
      "I am giving you a paper's title and abstract.",
      "Summarize the paper in as many sentences as I instruct.",
      "Do not include any preamble text to the summary,",
      "just give me the summary with no preface or intro sentence.",
      "Focus on the findings in the last 2 sentences of the abstract.",
      "If there is no abstract, just write abstract is not available.",
      "Highlight any novel contribution or claim made in the abstract.",
      "Briefly mention the key method or dataset, if explicitly stated.",
      "Indicate the tone of confidence (e.g., suggestive, strong evidence, preliminary).",
      "Optionally, provide a one-sentence lay summary for a general audience."
    )
) {
  stopifnot(
    is.numeric(nsentences),
    length(nsentences) == 1L,
    round(nsentences) == nsentences,
    nsentences > 0L
  )
  instructions <- paste(instructions, collapse = " ")
  prompt <- sprintf(
    "%s\nNumber of sentences in summary: %d\nTitle: %s\nAbstract: %s",
    instructions, nsentences, title, abstract
  )
  return(prompt)
}

#' @title Add Summarization Prompts to Articles
#'
#' @description
#' Adds a prompt column to a data frame of scientific articles, suitable for use with a language model summarization tool.
#' Prompts are generated using the `build_prompt()` function, based on article titles and abstracts.
#'
#' @usage
#' add_prompt(article, ...)
#'
#' @param article A data frame or tibble containing at least the columns `"title"` and `"abstract"`.
#' @param ... Additional arguments passed to `build_prompt()`, such as `nsentences`.
#'
#' @return A modified data frame of class `article_prompt`, including an additional column `"prompt"` containing structured summarization prompts.
#'
#' @details
#' The function checks for the presence of required columns before proceeding. It applies `build_prompt()` row-wise to generate summarization prompts.
#'
#' This function is typically used after retrieving articles via `get_articles()` or `get_article()`, to prepare data for summarization by a language model (e.g., using `ollama::generate()`).
#'
#' @examples
#' \dontrun{
#' papers <- get_articles("Nature Medicine")
#' papers_with_prompts <- add_prompt(papers, nsentences = 3)
#' cat(papers_with_prompts$prompt[1])
#' }
#'
#' @importFrom dplyr mutate
#' @export
#' @keywords summarization prompt-engineering text-processing
add_prompt <- function(article, ...) {
  if (!inherits(article, "data.frame")) {
    stop("Expecting a data frame.")
  }
  if (!"title" %in% colnames(article)) {
    stop("Expecting a column named 'title' in the data frame.")
  }
  if (!"abstract" %in% colnames(article)) {
    stop("Expecting a column named 'abstract' in the data frame.")
  }
  article <- article |>
    dplyr::mutate(prompt = build_prompt(title = .data$title, abstract = .data$abstract, ...))
  class(article) <- c("article_prompt", class(article))
  return(article)
}


#' @title Generate Summaries for Articles
#'
#' @description
#' This function generates concise summaries for each article in a given data frame, using the specified language model (LLM).
#' The summaries are generated based on the prompts previously added to the data frame.
#'
#' @usage
#' add_summary(article, model = "llama3.1", host = NULL)
#'
#' @param article A data frame or tibble containing at least a `"prompt"` column, which is created using `build_prompt()` or `add_prompt()`.
#' @param model Character string. The name of the LLM model to use for generating summaries. Default is `"llama3.1"`.
#' @param host Character string or NULL. The host to be used for the `ollamar::generate` function. Default is NULL.
#'
#' @return A modified data frame of class `article_summary`, including an additional column `"summary"` containing the generated summaries.
#'
#' @details
#' The function iterates over each article and generates a summary using the specified LLM model. A progress bar is shown to track the summarization process. Any newlines within the text fields are removed to ensure clean formatting. This function is typically used after applying `add_prompt()` to prepare a dataset for summarization.
#'
#' The progress bar updates for each article as the summaries are being generated. The final `summary` column will contain the output of the summarization process, ready for further processing or analysis.
#'
#' @examples
#' \dontrun{
#' papers <- get_article(journal = "Nature Medicine")
#' papers_with_prompts <- add_prompt(papers, nsentences = 3)
#' summarized_papers <- add_summary(papers_with_prompts)
#' }
#'
#' @importFrom dplyr mutate across everything
#' @importFrom ollamar generate
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @export
#' @keywords summarization text-processing language-model

add_summary <- function(article, model = "llama3.1", host = NULL) {
  message("Summarizing articles... please be patient as this might take several minutes...")
  if (!inherits(article, "data.frame")) stop("Expecting a data frame.")
  if (!"prompt" %in% colnames(article)) stop("Expecting a column named 'prompt' in the data frame.")
  num_articles <- nrow(article)
  progress_bar <- txtProgressBar(min = 0, max = num_articles, style = 3)
  suppressMessages({
    summaries <- character(num_articles)
    for (i in 1:num_articles) {
      summaries[i] <- ollamar::generate(model = model, prompt = article$prompt[i], output = "text", host = host)
      setTxtProgressBar(progress_bar, i)
    }
    article$summary <- summaries
  })
  article <- article |>
    dplyr::mutate(
      dplyr::across(dplyr::everything(), ~trimws(gsub("\n", " ", .)))
    )
  close(progress_bar)
  class(article) <- c("article_summary", class(article))
  return(article)
}


#' @title Filter Articles Based on Whitelist Terms
#'
#' @description
#' This function filters a data frame of articles, retaining only those that contain at least one of the specified whitelist terms
#' in either the title or abstract. This allows for easy extraction of articles relevant to a set of predefined topics.
#'
#' @usage
#' filter_articles(article, whitelist_terms)
#'
#' @param article A data frame or tibble containing at least the `"title"` and `"abstract"` columns.
#' @param whitelist_terms A character vector of terms that are used to filter articles by matching the title or abstract.
#'
#' @return A filtered data frame containing only articles where at least one of the whitelist terms is found in the title or abstract.
#'
#' @details
#' The function combines the "title" and "abstract" columns into a single text string and uses regular expression matching to search
#' for the presence of any of the specified whitelist terms. The search is case-insensitive. Only the articles that match one or more
#' of the whitelist terms will be retained in the output data frame.
#'
#' @examples
#' \dontrun{
#' papers <- get_article(journal = "Nature Medicine")
#' filtered_papers <- filter_articles(papers, whitelist_terms = c("CRISPR", "gene therapy"))
#' }
#'
#' @export
#' @keywords filtering text-search articles

filter_articles <- function(article, whitelist_terms) {
  if (!inherits(article, "data.frame")) stop("Expecting a data frame.")
  if (!all(c("title", "abstract") %in% colnames(article))) {
    stop("Expecting columns 'title' and 'abstract' in the data frame.")
  }
  combined_text <- paste(article$title, article$abstract)
  pattern <- paste(whitelist_terms, collapse = "|")
  filtered_articles <- article[grepl(pattern, combined_text, ignore.case = TRUE), ]
  return(filtered_articles)
}

























