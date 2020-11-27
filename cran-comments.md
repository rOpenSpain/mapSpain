# mapSpain v0.1.1

## Test environments

* local R installation, R version 4.0.3 on Windows 10 x64
* On github actions:
  * Mac OS X 10.15.7: release, oldrel.
  * Windows 10.0.17763:, devel, release, oldrel.
  * ubuntu 20.04: devel, release, oldrel, R 3.6.0.
* r-hub: devtools::check_rhub()
* win-builder: devel, release, oldrel

## R CMD check results

0 errors √ | 0 warnings √ | 1 note x

  Maintainer: 'Diego Hernang�mez <diego.hernangomezherrero@gmail.com>'
  New submission
  
  Possibly mis-spelled words in DESCRIPTION:
    CCAA (3:53)
    Eurostat (17:65)
    GISCO (17:9)

* This is a resubmission due to comments on CRAN incoming checks:
  * Bump version
  * On DESCRIPTION: 
    * Reduce lenght ot title (<65 characters).
    * Enclose 'leaflet' in single quotes.
  * Fix a bug on a malformed internal dataset and added a test on this.
  
