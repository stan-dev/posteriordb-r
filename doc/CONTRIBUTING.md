<!-- CONTRIBUTING.md is generated from CONTRIBUTING.Rmd. Please edit that file -->

Contributing to a posterior database with R
===========================================

First clone the posteriordb repository and install the posteriordb R
package.

    remotes::install_github("stan-dev/posteriordb-r")

Then loading the posteriordb R package and create a connection to the
local posteriordb. If you intend to add stan-code, also load rstan.

    library(posteriordb)
    library(rstan)

    # Set the environment variable PDB_PATH to you local posteriordb repo as
    Sys.setenv(PDB_PATH = "[path to local posteriordb]")

    # We setup a connection to the local posteriordb
    pdbl <- pdb_local()

Add Data
--------

The next step is to add and write down information about the data you
want to add. Below is a test example using data from the eight schools
example.

    x <- list(name = "test_eight_schools_data",
              keywords = c("test_data"),
              title = "A Test Data for the Eight Schools Model",
              description = "The data contain data from eight schools on SAT scores.",
              urls = "https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html",
              references = "rubin1981estimation",
              added_date = Sys.Date(),
              added_by = "Stanislaw Ulam")

    # Create the data info object
    di <- pdb_data_info(x)

    # Access the data
    file_path <- system.file("test_files/eight_schools.R", package = "posteriordb")
    # You can check the file with: file.edit(file_path)
    source(file_path)

    # Create the data object
    dat <- pdb_data(eight_schools, info = di)

We can now add the data object to the database (or remove it). The
function `write_pdb()` will write and zip the data.

    write_pdb(dat, pdbl)

If we want to remove the data object, we can simply use

    remove_pdb(dat, pdbl)

Note that we now added a reference `rubin1981estimation` that already
exists in the bibliography. If a new reference is added, it also needs
to be added in the bibtex bibliography.

Add Model
---------

Similarly, we can add stan-files and model information as follows (this
is a test case using the eight school model):

    x <- list(name = "test_eight_schools_model",
              keywords = c("test_model", "hiearchical"),
              title = "Test Non-Centered Model for Eight Schools",
              description = "An hiearchical model, non-centered parametrisation.",
              urls = c("https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html"),
              framework = "stan",
              references = NULL,
              added_by = "Stanislaw Ulam",
              added_date = Sys.Date())
    mi <- pdb_model_info(x)

    # Read in Stan model and compile the model
    file_path <- system.file("test_files/eight_schools_noncentered.stan", package = "posteriordb")
    smc <- readLines(file_path)
    sm <- rstan::stan_model(model_code = smc)
    mc <- model_code(sm, info = mi)

    # Write the model to the database
    write_pdb(mc, pdbl)

Similarly we remove the object with

    remove_pdb(mc, pdbl)

Add Posterior Object
--------------------

    x <- list(pdb_model_code = mc,
              pdb_data = dat,
              keywords = "posterior_keywords",
              urls = "posterior_urls",
              references = "rubin1981estimation",
              dimensions = list("dimensions" = 2, "dim" = 3),
              reference_posterior_name = NULL,
              added_date = Sys.Date(),
              added_by = "Stanislaw Ulam")
    po <- pdb_posterior(x, pdbl)

    # We write to the database as done previously
    write_pdb(po, pdbl)

And to remove the posterior, we simply use

    remove_pdb(po, pdbl)

Note that we need to add the model code and data first, before adding
the posterior.

Finally, we want to check that everything is in order with the
posterior. We do this as follows:

    check_pdb_posterior(po)

    ## Checking posterior 'test_eight_schools_data-test_eight_schools_model' ...

    ## - Posterior can be read.

    ## - The model_code can be read.

    ## - The data can be read.

    ## - The reference_posteriors_draws can be read (if it exists).

    ## - The posterior references exist in the bibliography.

    ## - Stan syntax is ok.

    ## - Stan can be run for the posterior.

    ##
    ## Posterior is ok.

If the posterior passes all checks, it can be added to the posteriordb,
so it is just to open a Pull Request with the proposed posterior.

Add Posterior Reference Draws
-----------------------------

If possible, we would like to supply posterior reference draws, i.e.,
draws of excellent quality from the posterior. The
[REFERENCE\_POSTERIOR\_DEFINITION.md](https://github.com/stan-dev/posteriordb/blob/master/doc/REFERENCE_POSTERIOR_DEFINITION.md)
contain details on quality criteria for reference posteriors.

    pdbl <- pdb_local()
    po <- posterior("test_eight_schools_data-test_eight_schools_model", pdbl)

    # Setup reference posterior info ----
    x <- list(name = posterior_name(po),
              inference = list(method = "stan_sampling",
                               method_arguments = list(chains = 10,
                                                       iter = 20000,
                                                       warmup = 10000,
                                                       thin = 10,
                                                       seed = 4711,
                                                       control = list(adapt_delta = 0.92))),
              diagnostics = NULL,
              checks_made = NULL,
              comments = "This is a test reference posterior",
              added_by = "Stanislaw Ulam",
              added_date = Sys.Date(),
              versions = NULL)

    # Create a reference posterior draws info object
    rpi <- pdb_reference_posterior_draws_info(x)

The reference posterior draws info contain all information to compute
the posterior using rstan. We then check that the reference posterior
criteria are fulfilled and add checked diagnostics to the object.

    # Compute the reference posterior
    rp <- compute_reference_posterior_draws(rpi, pdbl)
    rp <- check_reference_posterior_draws(x = rp)

We can now write the reference posterior draws to the posteriordb.

    write_pdb(rp, pdbl, overwrite = TRUE)

    # We can again check the posterior with
    check_pdb_posterior(po)

We can also remove the reference posterior object with

    remove_pdb(rp, pdbl)
