# Filtering names

    Code
      ss <- esp_get_rivers(cache_dir = cdir, name = "NIDNIFOMDF")
    Message
      ! No results for `name` "NIDNIFOMDF".
      i Returning empty <sf> object.

---

    Code
      ss <- esp_get_wetlands(cache_dir = cdir, name = "NIDNIFOMDF")
    Message
      ! No results for `name` "NIDNIFOMDF".
      i Returning empty <sf> object.

# Deprecations

    Code
      l <- esp_get_rivers(cache_dir = cdir, resolution = 10)
    Condition
      Warning:
      The `resolution` argument of `esp_get_rivers()` is deprecated as of mapSpain 1.0.0.
      i Resolution `3` (most detailed) would be always used.

---

    Code
      l1 <- esp_get_rivers(cache_dir = cdir, name = "Serena", spatialtype = "area")
    Condition
      Warning:
      The `spatialtype` argument of `esp_get_rivers()` is deprecated as of mapSpain 1.0.0.
      i Please use `esp_get_wetlands()` instead.
    Message
      i Redirecting the arguments to `mapSpain::esp_get_wetlands()`

