# Validate providers errors

    Code
      validate_provider(1)
    Condition
      Error in `validate_provider()`:
      ! `type` should be a named list (see `mapSpain::esp_make_provider()` or the name of a provider (see `mapSpain::esp_tiles_providers()`, not 1.

---

    Code
      validate_provider(list(a = 1, q = "2"))
    Condition
      Error in `validate_provider()`:
      ! A custom provider must be a named list with elements "id" and "q", missing "id" element. See `mapSpain::esp_make_provider()`.

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

