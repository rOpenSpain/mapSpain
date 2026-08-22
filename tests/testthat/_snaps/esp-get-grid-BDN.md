# BDN grid helpers reject invalid selections

    Code
      esp_get_grid_BDN("50")
    Condition
      Error in `esp_get_grid_BDN()`:
      ! `resolution` must be "10" or "5", not "50".

---

    Code
      esp_get_grid_BDN(type = "50")
    Condition
      Error in `esp_get_grid_BDN()`:
      ! `type` must be "main" or "canary", not "50".

---

    Code
      esp_get_grid_BDN_ccaa("Sevilla")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish Autonomous Communities and Cities codes found for "Sevilla".

---

    Code
      esp_get_grid_BDN_ccaa()
    Condition
      Error in `esp_get_grid_BDN_ccaa()`:
      ! `ccaa` must be supplied.

