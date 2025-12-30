# Deprecations

    Code
      db_redirected <- esp_get_railway(cache_dir = cdir, spatialtype = "point")
    Condition
      Warning:
      The `spatialtype` argument of `esp_get_railway()` is deprecated as of mapSpain 1.0.0.
      i Please use `esp_get_stations()` instead.
    Message
      i Redirecting the arguments to `mapSpain::esp_get_stations()`

