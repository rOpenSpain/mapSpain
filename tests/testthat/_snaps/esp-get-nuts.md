# esp_get_nuts() filters bundled data by regional identifiers

    Code
      s1 <- esp_get_nuts(region = b)
    Condition
      Warning:
      No Spanish NUTS codes found for "ES-PM", "ES-GC" and "ES-TF".

# esp_get_nuts() validates levels and file extensions

    Code
      esp_get_nuts(nuts_level = "docx", cache_dir = cdir)
    Condition
      Error in `esp_get_nuts()`:
      ! `nuts_level` must be "all", "0", "1", "2" or "3", not "docx".

# esp_get_nuts() agrees across bundled and downloaded data

    Code
      db_cached <- esp_get_nuts(verbose = TRUE, region = "Murcia")
    Message
      i Loaded from the bundled `mapSpain::esp_nuts_2024` dataset. Set `update_cache` to `TRUE` to reload from the source file.

# esp_get_nuts() validates and filters spatial types

    Code
      bn <- esp_get_nuts(spatialtype = "BN", resolution = "60", cache_dir = cdir)
    Condition
      Error in `esp_get_nuts()`:
      ! `spatialtype` must be "RG" or "LB", not "BN".

# esp_get_nuts() downloads historical datasets

    Code
      a3 <- esp_get_nuts(resolution = "60", year = 2016, cache_dir = cdir,
        nuts_level = 2, region = "Segovia")
    Condition
      Warning:
      No matches for `region` "Segovia".
      i Returning empty <sf> object.

