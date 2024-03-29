context("test-pdb")

test_that("model_names and data_names works as expected", {
  expect_silent(pdb_test <- pdb_local(Sys.getenv("PDB_PATH")))
  expect_silent(posteriors <- posterior_names(pdb_test))
  expect_silent(mn <- model_names(pdb_test))
  expect_silent(dn <- data_names(pdb_test))

  posteriors <- posteriors[grepl(x = posteriors, "-")]
  slpdat <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[1]]))
  slpmn <- unlist(lapply(strsplit(posteriors, split = "-"), FUN = function(x) x[[2]]))

  expect_true(all(slpmn %in% mn))
  expect_true(all(slpdat %in% dn))
})


test_that("pdb_version", {
  expect_silent(pdb_test <- pdb_local(Sys.getenv("PDB_PATH")))
  checkmate::expect_list(pdb_version(pdb_test))
  checkmate::expect_names(names(pdb_version(pdb_test)), must.include = "sha")
})


test_that("pdb_local", {
  assert_pdb_path_exists()
  if(on_github_actions()) skip_on_os("windows")

  pdb_path <- Sys.getenv("PDB_PATH")
  expect_silent(pdbl1 <- pdb_local(pdb_path))

  if(!on_covr()) expect_silent(pdbl2 <- pdb_local())
  expect_error(pdbl3 <- pdb_local(path = dirname(pdb_path)))
  expect_silent(pdbl4 <- pdb_local(file.path(pdb_path, "posterior_database", "data", "data")))
  expect_error(pdbl5 <- pdb_local(dirname(dirname(dirname(dirname(pdb_path))))))
  if(!on_covr()) expect_equal(pdbl1, pdbl2)
  expect_equal(pdbl1, pdbl4)
})


test_that("pdb_config", {
  if(on_github_actions()) skip_on_os("windows")
  skip_on_covr()
  pdb_path <- Sys.getenv("PDB_PATH")
  expect_silent(pdbl1 <- pdb_local())
  expect_silent(pdbl2 <- pdb_local(pdb_path))

  writeLines(text = c("type: \"local\""), con = ".pdb_config.yml")
  expect_silent(pdbc1 <- pdb_config())
  pdbc1b <- pdbc1; pdbc1b$.pdb_config.yml <- NULL
  writeLines(text = c("type: \"local\"",
                      paste0("path: \"", pdb_path, "\"")), con = ".pdb_config.yml")
  expect_silent(pdbc2 <- pdb_config())
  pdbc2b <- pdbc2; pdbc2b$.pdb_config.yml <- NULL

  expect_silent(pdbd <- pdb_default())
  pdbdb <- pdbd; pdbdb$.pdb_config.yml <- NULL

  expect_equal(pdbl1, pdbl2)
  expect_equal(pdbl1, pdbc1b)
  expect_equal(pdbl1, pdbc2b)
  expect_equal(pdbl1, pdbdb)

  expect_failure(expect_equal(pdbl1, pdbc1))
  expect_failure(expect_equal(pdbl1, pdbc2))
  expect_failure(expect_equal(pdbc1, pdbc2))
  expect_failure(expect_equal(pdbc1, pdbd))

  expect_equal(pdbc2, pdbd)

  file.remove(".pdb_config.yml")
})


test_that("pdb_config", {
  if(on_github_actions()) skip_on_os("windows")
  pdb_path <- Sys.getenv("PDB_PATH")
  expect_silent(pdbl <- pdb_local(pdb_path))

  writeLines(text = c("type: \"local\"",
                      paste0("path: \"", pdb_path, "\"")), con = ".pdb_config.yml")
  expect_silent(pdbc <- pdb_config())
  pdbcb <- pdbc; pdbcb$.pdb_config.yml <- NULL


  expect_output(print(pdbc), ".pdb_config.yml")

  expect_equal(pdbl, pdbcb)
  file.remove(".pdb_config.yml")
})
