# svSocket

[![Linux & OSX Build Status](https://travis-ci.com/SciViews/svSocket.svg )](https://travis-ci.com/SciViews/svSocket)
[![Win Build Status](https://ci.appveyor.com/api/projects/status/github/SciViews/svSocket?branch=master&svg=true)](https://ci.appveyor.com/project/phgrosjean/svSocket)
[![Coverage Status](https://img.shields.io/codecov/c/github/SciViews/svSocket/master.svg)
](https://codecov.io/github/SciViews/svSocket?branch=master)
[![CRAN Status](https://www.r-pkg.org/badges/version/svSocket)](https://cran.r-project.org/package=svSocket)
[![License](https://img.shields.io/badge/license-GPL-blue.svg)](https://www.gnu.org/licenses/gpl-2.0.html)

SciViews - socket server.

_Build badges are as follows (R versions at the time of the build)._
- _Status for devel R version for both Linux and Mac OS X at left._
- _Status for the latest stable version of R under Windows at right._ 


## Installation

### Latest stable version

The latest stable version of **svSocket** can simply be installed from [CRAN](http://cran.r-project.org):

```r
install.packages("svSocket")
```


### Development version

Make sure you have the **devtools** R package installed:

```r
install.packages("devtools")
```

Use `install_github()` to install the **svSocket** package from Github (source from **master** branch will be recompiled on your machine):

```r
devtools::install_github("SciViews/svSocket")
```

R should install all required dependencies automatically, and then it should compile and install **svSocket**.

Latest devel version of **svSocket** (source + Windows binaires for the latest stable version of R at the time of compilation) is also available from [appveyor](https://ci.appveyor.com/project/phgrosjean/svSocket/build/artifacts).


## Usage

Make the **svSocket** package available in your R session:

```r
library("svSocket")
```

Get help about this package:

```r
library(help = "svSocket")
help("svSocket-package")
```

For further instructions, please, refer to these help pages.


## Note to developers

This package used to be developed on R-Forge in the past. However, the latest [R-Forge version](https://r-forge.r-project.org/projects/sciviews/) was moved to this Github repository on 2016-03-18 (SVN version 569). **Please, do not use R-Forge anymore for SciViews development, use this Github repository instead.**
