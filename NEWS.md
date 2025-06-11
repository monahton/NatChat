# NatChat 1.1.0

# NatChat 1.0.1

* Second public release of **NatChat**, with enhanced functionality.
* Added `summarize_journal()` as a convenient wrapper to automate summarization and report generation in one step.
* Improved documentation andstructure.
* Minor bug fixes and internal enhancements.

# NatChat 1.0.0

* Initial stable release of **NatChat**.
* Provides functions to:
  - Retrieve articles from current issues of Nature Portfolio journals.
  - Build summarization prompts from titles and abstracts.
  - Generate summaries using local LLMs via the `ollamar` package.
  - Format outputs into markdown tables or export reports.
* Added `save_report()` to export article summaries in both CSV and HTML formats.
* Inspired by the [`biorecap`](https://github.com/stephenturner/biorecap) package but tailored for Nature journals.
* Targeted at researchers, clinicians, and educators who want quick insights from high-impact journals.

# NatChat 0.0.0.9000

* Initial development version of **NatChat** (pre-release).
* Established core functionality: scraping, prompting, summarizing, and formatting.
