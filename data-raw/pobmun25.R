## code to prepare `pobmun25` dataset goes here

library(tidyverse)

# https://www.ine.es/dynt3/inebase/es/index.htm?padre=525

esp_hlp_utf8 <- function(data.sf) {
  f <- data.sf
  ncol <- length(colnames(f))

  for (i in seq(1, ncol)) {
    if (is.character(f[, i])) {
      f[, i] <- enc2utf8(f[, i])
    }
  }
  return(f)
}

pobmun25 <- readxl::read_xlsx("data-raw/input/pobmun25.xlsx", skip = 1)
pobmun25 <- esp_hlp_utf8(pobmun25)
names(pobmun25) <- c(
  "cpro",
  "provincia",
  "cmun",
  "name",
  "pob25",
  "men",
  "women"
)

usethis::use_data(pobmun25, overwrite = TRUE)
