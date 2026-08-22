# esp_get_hydrobasin() validates options and returns both domains

    Code
      esp_get_hydrobasin(epsg = 3367)
    Condition
      Error in `esp_get_hydrobasin()`:
      ! `epsg` must be "4326", "4258", "3035" or "3857", not "3367".

---

    Code
      esp_get_hydrobasin(domain = "f")
    Condition
      Error in `esp_get_hydrobasin()`:
      ! `domain` must be "land" or "landsea", not "f".

