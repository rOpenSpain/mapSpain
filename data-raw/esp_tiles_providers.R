## code to prepare `esp_tiles_providers` dataset goes here
rm(list = ls())
source("./data-raw/helperfuns.R")

library(dplyr)
library(tidyverse)
library(readxl)

df <-
  read_xlsx("./data-raw/input/leafletproviders-ESP.xlsx") %>%
  esp_hlp_utf8() %>%
  as.data.frame()

unique(df$field)

df_pivoted <- df %>%
  pivot_wider(
    values_from = value,
    names_from = field
  )


url_static <- "https://rts.larioja.org/mapa-base/rioja/{z}/{x}/{y}.png"
# Helper to split urls
esp_hlp_split_url <- function(url_static) {
  split <- unlist(strsplit(url_static, "?", fixed = TRUE))

  urlsplit <- list()
  if (length(split) > 1) {
    urlsplit$q <- paste0(split[1], "?")
  } else {
    urlsplit$q <- split[1]
  }
  opts <- unlist(strsplit(split[2], "&"))

  names_opts <- vapply(
    opts,
    function(x) {
      n <- strsplit(x, "=", fixed = TRUE)
      return(unlist(n)[1])
    },
    FUN.VALUE = character(1)
  )

  values_opts <- vapply(
    opts,
    function(x) {
      n <- strsplit(x, "=", fixed = TRUE)

      unl <- unlist(n)
      if (length(unl) == 2) {
        return(unl[2])
      }
      return("")
    },
    FUN.VALUE = character(1)
  )

  names(values_opts) <- tolower(names_opts)

  urlsplit <- modifyList(urlsplit, as.list(values_opts))

  return(urlsplit)
}

len_prov <- seq_len(nrow(df_pivoted))

x <- 1

esp_tiles_providers <- lapply(len_prov, function(x) {
  prov <- df_pivoted[x, ]

  url_st <- as.vector(prov$url_static)

  url <- esp_hlp_split_url(url_st)

  # Compose list
  static <- c(
    list(attribution = as.vector(prov$attribution_static)),
    url
  )
  # Add additional options for leaflet
  leaflet <- list(
    attribution = as.vector(prov$attribution),
    minZoom = as.vector(prov$minZoom)
  )

  # Cleanup
  leaflet <- leaflet[!is.na(leaflet)]

  # Final output

  l <- list(
    static = static,
    leaflet = leaflet
  )

  return(l)
})

names(esp_tiles_providers) <- df_pivoted$provider
usethis::use_data(esp_tiles_providers, overwrite = TRUE)

# Check

rm(list = ls())
# Try

esp_set_cache_dir("~/R/maplibs/GISCO", install = TRUE, overwrite = TRUE)

esp_hlp_detect_cache_dir()
devtools::load_all()

# Try MDT
library(tidyterra)
ccaa <- esp_get_ccaa(c("LA Rioja"), epsg = 3857)
tile <- esp_getTiles(ccaa, "PNOA", crop = FALSE, verbose = TRUE)

ggplot2::ggplot() +
  geom_spatraster_rgb(data = tile)

library(leaflet)

leaflet() %>%
  setView(
    lat = 40.4166,
    lng = -3.7038400,
    zoom = 10
  ) %>%
  addProviderEspTiles(provider = "IDErioja.Claro") %>%
  addProviderEspTiles(
    provider = "CaminoDeSantiago",
    options = list(transparent = TRUE)
  )

names(mapSpain::esp_tiles_providers)

esp_tiles_providers$IDErioja$static$q
provider <- "IGNBase.Todo"

tt <- esp_tiles_providers
