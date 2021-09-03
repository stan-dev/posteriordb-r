context("test-pdb_github")

test_that("posteriordb:::check_pdb indicates that github PDB is ok", {
  skip_if(is.null(github_pat()))

  expect_silent(pdb_github_test1 <- pdb_github("stan-dev/posteriordb/posterior_database", ref = "master"))
  expect_silent(pdb_github_test2 <- pdb_github("stan-dev/posteriordb", ref = "master"))
  expect_silent(pdb_github_test3 <- pdb_github("stan-dev/posteriordb/posterior_database@master"))
  expect_output(print(pdb_github_test1), "Posterior Database")
  expect_output(print(pdb_github_test1), "github")
  expect_equal(pdb_github_test1$pdb_id, pdb_github_test2$pdb_id)
  expect_equal(pdb_github_test1$pdb_id, pdb_github_test3$pdb_id)
  posteriordb:::pdb_clear_cache(pdb_github_test1)
})

test_that("model_names, data_names and posterior_names work", {
  skip_if(is.null(github_pat()))

  expect_silent(pdb_test <- pdb_local(Sys.getenv("PDB_PATH")))
  posteriordb:::pdb_clear_cache(pdb_test)
  expect_silent(nms <- posterior_names(pdb_test))
  checkmate::expect_choice("eight_schools-eight_schools_centered", nms)
  expect_silent(nms <- data_names(pdb = pdb_test))
  checkmate::expect_choice("eight_schools", nms)
  expect_silent(nms <- model_names(pdb_test))
  checkmate::expect_choice("eight_schools_centered", nms)
  expect_silent(nms <- reference_posterior_names(pdb_test, "draws"))
  checkmate::expect_choice("eight_schools-eight_schools_noncentered", nms)


  expect_silent(pdb_github_test <- pdb_github("stan-dev/posteriordb/posterior_database@master"))
  posteriordb:::pdb_clear_cache(pdb_github_test)
  expect_silent(nms <- posterior_names(pdb_github_test))
  checkmate::expect_choice("eight_schools-eight_schools_centered", nms)
  expect_silent(nms <- data_names(pdb = pdb_github_test))
  checkmate::expect_choice("eight_schools", nms)
  expect_silent(nms <- model_names(pdb_github_test))
  checkmate::expect_choice("eight_schools_centered", nms)
  expect_silent(nms <- reference_posterior_names(pdb_github_test, "draws"))
  checkmate::expect_choice("eight_schools-eight_schools_noncentered", nms)
  posteriordb:::pdb_clear_cache(pdb_github_test)
})


test_that("pdb_default is github", {
  skip_if(is.null(github_pat()))

  expect_silent(pdb_default_test <- pdb_default())
  expect_silent(pdb_github_test <- pdb_github("stan-dev/posteriordb/posterior_database"))
  expect_equal(pdb_default_test, pdb_github_test)
})
