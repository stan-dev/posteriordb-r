context("test-posterior_names")

test_that("posterior_names handels list of objects", {

  expect_silent(pdb_test <- pdb_local())
  expect_silent(pns <- posterior_names(pdb_test, pdb_test))
  expect_silent(pns_list <- posterior_names(list(pdb_test, pdb_test)))
  expect_equal(pns_list[[1]], pns)

})
