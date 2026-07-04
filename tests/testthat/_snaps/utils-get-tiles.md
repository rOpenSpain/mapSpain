# Validate providers errors

    Code
      validate_provider(1)
    Condition
      Error in `validate_provider()`:
      ! `type` must be a named list (see `mapSpain::esp_make_provider()`) or the name of a provider (see `?mapSpain::esp_tiles_providers()`), not a number.

---

    Code
      validate_provider(list(a = 1, q = "2"))
    Condition
      Error in `validate_provider()`:
      ! A custom provider must be a named list with fields id and q, missing id field. See `mapSpain::esp_make_provider()`.

# Validate all internals

    Code
      unique(prov_type)
    Output
      [1] "WMTS" "WMS" 

---

    Code
      unique(in_epsg)
    Output
      [1] "EPSG:3857"

