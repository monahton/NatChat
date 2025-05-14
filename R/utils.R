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
