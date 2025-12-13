# Errors

    Code
      esp_get_grid_BDN("50")
    Condition
      Error:
      ! `resolution` should be one of "10" or "5", not "50".

---

    Code
      esp_get_grid_BDN(type = "50")
    Condition
      Error:
      ! `type` should be one of "main" or "canary", not "50".

---

    Code
      esp_get_grid_BDN_ccaa("Sevilla")
    Condition
      Warning in `esp_hlp_all2ccaa()`:
      Sevilla does not return a Autonomous Community
      Error in `esp_get_grid_BDN_ccaa()`:
      ! `ccaa = Sevilla` not mapped to a known CCAA.

---

    Code
      esp_get_grid_BDN_ccaa()
    Condition
      Error in `esp_get_grid_BDN_ccaa()`:
      ! `ccaa` can't be missing value.

