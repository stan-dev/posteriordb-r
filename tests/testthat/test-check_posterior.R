context("test-check_posterior")


test_that("test checking a posterior", {

  expect_silent(pdb <- pdb_test <- pdb_local())

  expect_silent(po <- posterior("eight_schools", pdb_test))

  expect_message(check_pdb_posterior(po, run_stan_code_checks = TRUE))

})


