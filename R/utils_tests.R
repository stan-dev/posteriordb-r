# Test utils - only used for tests

on_covr <- function() identical(Sys.getenv("R_COVR"), "true")
on_windows <- function() identical(tolower(Sys.info()[["sysname"]]), "windows")
on_github_actions <- function() identical(Sys.getenv("GITHUB_ACTIONS"), "true")

assert_pdb_path_exists <- function() {
  pdb_path <- Sys.getenv("PDB_PATH")
  if(pdb_path == ""){
    stop("Need to set Sys.setenv(PDB_PATH='....') for testing")
  }
}
