% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{build_prompt}
\alias{build_prompt}
\title{Construct a Text Prompt for Summarizing an Article}
\usage{
build_prompt(
  title,
  abstract,
  nsentences = 3L,
  instructions = c("You will receive a paper's title and abstract as input.",
    "Provide a concise summary with exactly the number of sentences specified.",
    "Do not include introductory phrases or preamble text.",
    "Start directly with the summary; avoid any framing statements.",
    "Focus on key findings, especially of last two sentences of the abstract.",
    "If the abstract is missing, reply explicitly with 'Abstract is not available.'",
    "Highlight any novel contributions, claims, or innovations in the abstract.",
    "Mention main methods or datasets only if explicitly stated in the abstract.", 
    
    "Indicate the strength and tone of evidence.",
    "Optionally,add a one-sentence lay summary for a non-specialist audience.")
)
}
\arguments{
\item{title}{Character string. The title of the article.}

\item{abstract}{Character string. The abstract of the article. If unavailable, include a default message.}

\item{nsentences}{Integer. The number of sentences required in the summary. Default is 3.
Must be a positive whole number.}

\item{instructions}{Character vector. A set of instructions guiding the summarization. Defaults to a structured template emphasizing main findings, methods, novelty, and tone.}
}
\value{
A character string representing a structured prompt for use with a language model summarization tool.
}
\description{
Builds a structured prompt from an article's title and abstract, designed for input to a language model.
The prompt emphasizes extracting key findings, methodology, and tone, and is customizable via instructions.
}
\details{
The generated prompt follows a structured format:
\itemize{
\item Lists the instructions (customizable via \code{instructions}).
\item States the number of summary sentences required (\code{nsentences}).
\item Embeds the article title and abstract.
\item If the abstract is missing or not available, the prompt explicitly states this.
}

The default \code{instructions} vector can be modified to adapt the tone or focus of the summary, such as prioritizing method, dataset, confidence tone, or accessibility for non-specialists.
}
\examples{
title <- "Deep Learning for Genomic Data Analysis"
abstract <- "This study explores deep learning in diverse tasks highlighting predictive accuracy."
prompt <- build_prompt(title, abstract, nsentences = 3)
cat(prompt)

}
\keyword{NLP}
\keyword{prompt}
