context("test-check_posterior_draws")

test_that("test-check_posterior_draws", {
  assert_pdb_path_exists()
  expect_silent(pdb_test <- pdb_local())

  expect_silent(rp <- reference_posterior_draws(x = "eight_schools-eight_schools_noncentered", pdb_test))
  expect_silent(rp1 <- check_reference_posterior_draws(x = rp))
  expect_silent(rp2 <- check_reference_posterior_draws(x = "eight_schools-eight_schools_noncentered", pdb = pdb_test))
  po <- pdb_posterior("eight_schools-eight_schools_noncentered", pdb_test)
  expect_silent(rp3 <- check_reference_posterior_draws(x = po))

  expect_equal(rp1, rp2)
  expect_equal(rp1, rp3)
})

test_that("check_pdb_posterior works", {
  assert_pdb_path_exists()
  expect_silent(pdb_test <- pdb_local())

  po <- pdb_posterior("eight_schools-eight_schools_noncentered", pdb_test)

  if(on_github_actions()) skip_on_os("linux") # Currently problem with stringi on ubuntu (2021-03-10)
  expect_message(check_pdb_posterior(po, run_stan_code_checks = FALSE), regexp = "Posterior is ok.")
})
