# 'SciViews::R' - Socket Server

<!-- badges: start -->

[![R-CMD-check](https://github.com/SciViews/svSocket/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SciViews/svSocket/actions/workflows/R-CMD-check.yaml) [![Codecov test coverage](https://codecov.io/gh/SciViews/svSocket/branch/main/graph/badge.svg)](https://app.codecov.io/gh/SciViews/svSocket?branch=main) [![CRAN status](https://www.r-pkg.org/badges/version/svSocket)](https://cran.r-project.org/package=svSocket) [![r-universe status](https://sciviews.r-universe.dev/badges/svSocket)](https://sciviews.r-universe.dev/svSocket) [![License](https://img.shields.io/badge/license-GPL-blue.svg)](https://www.gnu.org/licenses/gpl-2.0.html) [![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

<!-- badges: end -->

A socket server that allows for another process to connect to R and to interact with it as if it was at the command line directly.

## Installation

The latest stable version of {svSocket} can simply be installed from [CRAN](http://cran.r-project.org):

``` r
install.packages("svSocket")
```

You can also install the latest development version. Make sure you have the {remotes} R package installed:

``` r
install.packages("remotes")
```

Use `install_github()` to install the {svSocket} package from Github (source from **master** branch will be recompiled on your machine):

``` r
remotes::install_github("SciViews/svSocket")
```

R should install all required dependencies automatically, and then it should compile and install {svSocket}.


## Further explore {svSocket}

You can get further help about this package this way: Make the {svSocket} package available in your R session:

``` r
library("svSocket")
```

Get help about this package:

``` r
library(help = "svSocket")
help("svSocket-package")
vignette("svSocket") # None is installed with install_github()
```

For further instructions, please, refer to these help pages at <https://www.sciviews.org/svSocket/>.

## Code of Conduct

Please note that the {svSocket} project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

## Note to developers

This package used to be developed on R-Forge in the past. However, the latest [R-Forge version](https://r-forge.r-project.org/projects/sciviews/) was moved to this Github repository on 2016-03-18 (SVN version 569). **Please, do not use R-Forge anymore for SciViews development, use this Github repository instead.**
