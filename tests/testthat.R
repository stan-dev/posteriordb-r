library(testthat)
library(posteriordb)

if (getOption("pdb_path", Sys.getenv("PDB_PATH")) == "") {
  tmp <- tempdir(check = TRUE)
  git2r::clone("https://github.com/stan-dev/posteriordb",
              local_path = file.path(tmp, "posteriordb"))
  Sys.setenv(PDB_PATH = file.path(tmp, "posteriordb"))
}

test_check("posteriordb")
