# comarcas online

    Code
      esp_get_comarca(region = "XX", cache_dir = cdir)
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "XX".

---

    Code
      esp_get_comarca(epsg = "5689", cache_dir = cdir)
    Condition
      Error:
      ! `epsg` must be "4326", "4258", "3035", or "3857", not "5689".

---

    Code
      nemty <- esp_get_comarca(comarca = "XX", cache_dir = cdir)
    Message
      ! The selected `region`, `comarca` or filter combination does not return any results.
      i Returning empty <sf> object.

