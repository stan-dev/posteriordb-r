context("test-bibliography")

test_that("bibliography works as expected", {
  assert_pdb_path_exists()
  expect_silent(pdb_test <- pdb_local())
  expect_silent(bib <- bibliography(pdb_test))

})
