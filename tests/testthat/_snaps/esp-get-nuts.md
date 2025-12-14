# Valid inputs

    Code
      esp_get_nuts(ext = "docx")
    Condition
      Error:
      ! `ext` should be one of "geojson", "gpkg" or "shp", not "docx".

---

    Code
      esp_get_nuts(nuts_level = "docx")
    Condition
      Error:
      ! `nuts_level` should be one of "all", "0", "1", "2" or "3", not "docx".

# Cached dataset vs updated

    Code
      db_cached <- esp_get_nuts(verbose = TRUE, region = "Murcia")
    Message
      i Loaded from `?mapSpain::esp_nuts_2024()` dataset. Use `update_cache = TRUE` to re-load from file

# Spatial types

    Code
      bn <- esp_get_nuts(spatialtype = "BN", resolution = "60")
    Condition
      Error:
      ! `spatialtype` should be one of "RG" or "LB", not "BN".

