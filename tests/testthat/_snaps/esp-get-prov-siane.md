# prov online

    Code
      esp_get_prov_siane(prov = "Menorca", cache_dir = cdir)
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "Menorca".

---

    Code
      esp_get_prov_siane(prov = "ES6x", cache_dir = cdir)
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "ES6x".

---

    Code
      n <- esp_get_prov_siane(prov = f$nuts3.code, cache_dir = cdir)
    Message
      ! No Spanish province codes found for "ES531", "ES532", "ES533", "ES704", "ES705", "ES708", "ES703", "ES706", "ES707", and "ES709".

