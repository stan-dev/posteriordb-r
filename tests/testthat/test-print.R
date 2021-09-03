context("test-print")

test_that("All PPFs are printed", {

  expect_silent(pdb_test <- pdb_local())
  expect_silent(po <- posterior("eight_schools-eight_schools_noncentered", pdb = pdb_test))

  expect_output(print(model_info(po)), "stan")

})
