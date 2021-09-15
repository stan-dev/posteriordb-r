<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/stan-dev/posteriordb-r/actions/workflows/check-release.yaml/badge.svg)](https://github.com/stan-dev/posteriordb-r/actions/workflows/check-release.yaml)
[![Codecov test
coverage](https://codecov.io/gh/stan-dev/posteriordb-r/branch/main/graph/badge.svg)](https://codecov.io/gh/stan-dev/posteriordb-r?branch=main)
<!-- badges: end -->

`posteriordb-r`: an R package to work with `posteriordb`
========================================================

This repository contain the R package to easily work with the
[posteriordb](https://github.com/stan-dev/posteriordb) repository. The R
package included database contain convenience functions to access data,
model code and information for individual posteriors, models, data and
draws.

Installation
------------

To install the package To install only the R package and then access the
posteriors remotely, just install the package from GitHub using the
`remotes` package.

``` r
remotes::install_github("stan-dev/posteriordb-r")
```

To load the package, just run.

``` r
library(posteriordb)
```

Connect to the posterior database
---------------------------------

First we create the posterior database to use, here we can use the
database locally (if the `posteriordb` repo is cloned).

``` r
my_pdb <- pdb_local()
```

The above code requires that your working directory is in the main
folder of the cloned repository. Otherwise we can use the `path`
argument.

We can also simply use the github repository directly to access the
data.

``` r
my_pdb <- pdb_github()
```

Independent of the posterior database used, the following works for all.

Contributing content using R
----------------------------

If you want to contribute to a posteriordb, see
[https://github.com/stan-dev/posteriordb-r/blob/main/docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

Access content
--------------

To list the posteriors available in the database, use
`posterior_names()`.

``` r
pos <- posterior_names(my_pdb)
head(pos)
```

    ## [1] "arK-arK"                         "arma-arma11"                    
    ## [3] "bball_drive_event_0-hmm_drive_0" "bball_drive_event_1-hmm_drive_1"
    ## [5] "butterfly-multi_occupancy"       "diamonds-diamonds"

In the same fashion, we can list data and models included in the
database as

``` r
mn <- model_names(my_pdb)
head(mn)
```

    ## [1] "2pl_latent_reg_irt" "accel_gp"           "accel_splines"     
    ## [4] "arK"                "arma11"             "blr"

``` r
dn <- data_names(my_pdb)
head(dn)
```

    ## [1] "arK"                 "arma"                "bball_drive_event_0"
    ## [4] "bball_drive_event_1" "butterfly"           "diamonds"

We can also get all information on each individual posterior as a tibble
with

``` r
pos <- posteriors_tbl_df(my_pdb)
head(pos)
```

    ## # A tibble: 6 × 7
    ##   name     model_name  reference_posteri… data_name added_by added_date keywords
    ##   <chr>    <chr>       <chr>              <chr>     <chr>    <date>     <chr>   
    ## 1 arK-arK  arK         arK-arK            arK       Mans Ma… 2019-11-19 stan_be…
    ## 2 arma-ar… arma11      arma-arma11        arma      Mans Ma… 2020-01-08 stan_be…
    ## 3 bball_d… hmm_drive_0 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_ex…
    ## 4 bball_d… hmm_drive_0 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_be…
    ## 5 bball_d… hmm_drive_1 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_ex…
    ## 6 bball_d… hmm_drive_1 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_be…

The posterior’s name is made up of the data and model fitted to the
data. Together, these two uniquely define a posterior distribution. To
access a posterior object we can use the model name.

``` r
po <- posterior("eight_schools-eight_schools_centered", my_pdb)
```

From the posterior object, we can access data, model code (i.e., Stan
code in this case) and a lot of other useful information.

``` r
dat <- pdb_data(po)
dat
```

    ## $J
    ## [1] 8
    ## 
    ## $y
    ## [1] 28  8 -3  7 -1  1 18 12
    ## 
    ## $sigma
    ## [1] 15 10 16 11  9 11 10 18

``` r
code <- stan_code(po)
code
```

    ## data {
    ##   int <lower=0> J; // number of schools
    ##   real y[J]; // estimated treatment
    ##   real<lower=0> sigma[J]; // std of estimated effect
    ## }
    ## parameters {
    ##   real theta[J]; // treatment effect in school j
    ##   real mu; // hyper-parameter of mean
    ##   real<lower=0> tau; // hyper-parameter of sdv
    ## }
    ## model {
    ##   tau ~ cauchy(0, 5); // a non-informative prior
    ##   theta ~ normal(mu, tau);
    ##   y ~ normal(theta, sigma);
    ##   mu ~ normal(0, 5);
    ## }

We can also access the paths to data after they have been unzipped and
copied to the cache directory set in `pdb` (the R temp directory by
default).

``` r
dfp <- data_file_path(po)
dfp
```

    ## [1] "/var/folders/8x/bgssdq5n6dx1_ydrhq1zgrym0000gn/T//RtmpEoOiTD/posteriordb_cache/data/data/eight_schools.json"

``` r
scfp <- stan_code_file_path(po)
scfp
```

    ## [1] "/var/folders/8x/bgssdq5n6dx1_ydrhq1zgrym0000gn/T//RtmpEoOiTD/posteriordb_cache/models/stan/eight_schools_centered.stan"

We can also access information regarding the model and the data used to
compute the posterior.

``` r
data_info(po)
```

    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)

``` r
model_info(po)
```

    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools
    ## Frameworks: 'stan', 'pymc3'

Note that the references are referencing to BibTeX items that can be
found in `content/references/references.bib`.

We can access most of the posterior information as a `tbl_df` using

``` r
tbl <- posteriors_tbl_df(my_pdb)
head(tbl)
```

    ## # A tibble: 6 × 7
    ##   name     model_name  reference_posteri… data_name added_by added_date keywords
    ##   <chr>    <chr>       <chr>              <chr>     <chr>    <date>     <chr>   
    ## 1 arK-arK  arK         arK-arK            arK       Mans Ma… 2019-11-19 stan_be…
    ## 2 arma-ar… arma11      arma-arma11        arma      Mans Ma… 2020-01-08 stan_be…
    ## 3 bball_d… hmm_drive_0 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_ex…
    ## 4 bball_d… hmm_drive_0 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_be…
    ## 5 bball_d… hmm_drive_1 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_ex…
    ## 6 bball_d… hmm_drive_1 bball_drive_event… bball_dr… Oliver … 2020-05-10 stan_be…

In addition, we can also access a list of posteriors with
`filter_posteriors()`. The filtering function follows dplyr filter
semantics based on the posterior tibble.

``` r
pos <- filter_posteriors(pdb = my_pdb, data_name == "eight_schools")
pos
```

    ## [[1]]
    ## Posterior (eight_schools-eight_schools_centered)
    ## 
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ## 
    ## Model: eight_schools_centered
    ## A centered hiearchical model for 8 schools
    ## Frameworks: 'stan', 'pymc3'
    ## 
    ## [[2]]
    ## Posterior (eight_schools-eight_schools_noncentered)
    ## 
    ## Data: eight_schools
    ## The 8 schools dataset of Rubin (1981)
    ## 
    ## Model: eight_schools_noncentered
    ## A non-centered hiearchical model for 8 schools
    ## Frameworks: 'stan'

To access reference posterior draws we use
`reference_posterior_draws()`.

``` r
rpd <- reference_posterior_draws(po)
```

The function `reference_posterior_draws()` returns a posterior
`draws_list` object that can be summarized and transformed using the
`posterior` package.

``` r
posterior::summarize_draws(rpd)
```

    ## # A tibble: 10 × 10
    ##    variable  mean median    sd   mad     q5   q95  rhat ess_bulk ess_tail
    ##    <chr>    <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>    <dbl>    <dbl>
    ##  1 theta[1]  6.15   5.59  5.62  4.56 -1.68  16.3   1.00   10095.    9732.
    ##  2 theta[2]  4.94   4.77  4.65  4.14 -2.22  12.8   1.00   10049.   10139.
    ##  3 theta[3]  3.91   4.11  5.28  4.48 -4.91  11.8   1.00    9533.    9339.
    ##  4 theta[4]  4.80   4.70  4.77  4.22 -2.67  12.6   1.00   10026.    9666.
    ##  5 theta[5]  3.61   3.82  4.61  4.15 -4.26  10.6   1.00    9922.   10207.
    ##  6 theta[6]  4.05   4.16  4.80  4.32 -3.87  11.5   1.00    9783.   10039.
    ##  7 theta[7]  6.32   5.80  5.00  4.39 -0.855 15.3   1.00   10039.    9690.
    ##  8 theta[8]  4.88   4.79  5.32  4.47 -3.32  13.5   1.00    9605.    9871.
    ##  9 mu        4.41   4.36  3.31  3.30 -0.936  9.83  1.00   10041.    9973.
    ## 10 tau       3.60   2.75  3.20  2.55  0.257  9.73  1.00    9989.    9992.

To access information on the reference posterior we can use
`reference_posterior_draws_info()` or just use `info()` on the reference
posterior. This give soime basic information on how the reference
posterior was computed.

``` r
rpi <- reference_posterior_draws_info(po)
rpi
```

    ## Posterior: eight_schools-eight_schools_noncentered
    ## Method: stan_sampling (rstan 2.21.1)
    ## Arguments:
    ##   chains: 10
    ##   iter: 20000
    ##   warmup: 10000
    ##   thin: 10
    ##   seed: 4711
    ##     adapt_delta: 0.95

``` r
info(rpd)
```

    ## Posterior: eight_schools-eight_schools_noncentered
    ## Method: stan_sampling (rstan 2.21.1)
    ## Arguments:
    ##   chains: 10
    ##   iter: 20000
    ##   warmup: 10000
    ##   thin: 10
    ##   seed: 4711
    ##     adapt_delta: 0.95

Contributing content using R
----------------------------

If you want to contribute to a posteriordb, see
[https://github.com/stan-dev/posteriordb-r/blob/main/docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).
