context("test-README.md")

test_that("README.md works as stated", {
  skip_on_cran()
  if(on_github_actions()) skip_on_os("windows")

  if(on_github_actions()) {
    ACTIONS_WORKSPACE <- Sys.getenv("GITHUB_WORKSPACE")
    readme_path <- file.path(ACTIONS_WORKSPACE, "README.md")
  } else {
    readme_path <- test_path("../../README.md")
  }
  skip_if(!file.exists(readme_path))

  expect_silent(rmarkdown::render(input = readme_path, output_file = "tmp.md", output_format = rmarkdown::md_document(variant = "gfm"), quiet = TRUE))

})
