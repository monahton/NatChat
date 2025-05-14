test_that("nat_journals returns a tibble with correct columns", {
  result <- nat_journals()
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("journal", "slug") %in% colnames(result)))
})

test_that("nat_journals returns full list when no input is provided", {
  result <- nat_journals()
  expect_gt(nrow(result), 60)  # Should contain many journals
})

test_that("nat_journals filters correctly (case-insensitive match)", {
  result1 <- nat_journals("Nature Medicine")
  result2 <- nat_journals("nature medicine")
  expect_equal(nrow(result1), 1)
  expect_equal(nrow(result2), 1)
  expect_equal(result1$slug, "nm")
  expect_equal(result2$slug, "nm")
})

test_that("nat_journals returns empty tibble for unknown journal", {
  result <- nat_journals("Nonexistent Journal")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

