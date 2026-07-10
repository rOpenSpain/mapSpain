# hypsobath errors

    Code
      esp_get_hypsobath(epsg = 3367)
    Condition
      Error:
      ! `epsg` must be "4326", "4258", "3035", or "3857", not "3367".

---

    Code
      esp_get_hypsobath(spatialtype = "f")
    Condition
      Error:
      ! `spatialtype` must be "area" or "line", not "f".

---

    Code
      esp_get_hypsobath(resolution = "10")
    Condition
      Error:
      ! `resolution` must be "3" or "6.5", not "10".

