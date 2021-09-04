context("test-pdb-cache")

test_that("remove reference posterior cache", {

  expect_silent(pdb_test <- pdb_local())
  posteriordb:::pdb_clear_cache(pdb_test)

  expect_length(dir(pdb_test$cache_path, recursive = TRUE),0)

  po <- posterior("8_schools", pdb_test)
  expect_false(any(grepl(dir(pdb_test$cache_path, recursive = TRUE),
                        pattern = "draws/draws/eight_schools-eight_schools_noncentered\\.json")))
  rp <- reference_posterior_draws(po)
  expect_true(any(grepl(dir(pdb_test$cache_path, recursive = TRUE),
                    pattern = "draws/draws/eight_schools-eight_schools_noncentered\\.json")))
  pdb_cache_rm(x = rp)
  expect_false(any(grepl(dir(pdb_test$cache_path, recursive = TRUE),
                         pattern = "draws/draws/eight_schools-eight_schools_noncentered\\.json")))

})


test_that("remove data cache", {

  expect_silent(pdb_test <- pdb_local())
  pdb_clear_cache(pdb_test)

  expect_length(dir(pdb_test$cache_path, recursive = TRUE),0)

  po <- posterior("8_schools", pdb_test)
  expect_false(any(grepl(dir(pdb_test$cache_path, recursive = TRUE),
                         pattern = "data/data/eight_schools\\.json")))
  sd <- get_data(po)
  expect_true(any(grepl(dir(pdb_test$cache_path, recursive = TRUE),
                        pattern = "data/data/eight_schools\\.json")))
  pdb_cache_rm(x = sd)
  expect_false(any(grepl(dir(pdb_test$cache_path, recursive = TRUE),
                         pattern = "data/data/eight_schools\\.json")))
})
