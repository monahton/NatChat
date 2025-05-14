# tests/testthat/test-get_articles.R

test_that("get_articles returns a tibble with correct structure", {
  result <- suppressMessages(get_articles("Nature Biotechnology"))
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("title", "url", "abstract", "source") %in% colnames(result)))
})

test_that("get_articles works for all supported journals", {
  journals <- nat_journals()$journal
  for (j in journals) {
    expect_silent({
      suppressMessages({
        result <- get_articles(j)
        expect_s3_class(result, "tbl_df")
      })
    })
  }
})

test_that("get_articles returns informative error for unsupported journals", {
  expect_error(
    get_articles("Unsupported Journal"),
    regexp = "The journal name 'Unsupported Journal' is not supported",
    fixed = TRUE
  )
})

