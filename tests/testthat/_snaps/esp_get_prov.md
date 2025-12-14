# prov offline

    Code
      esp_get_prov(prov = "FFF")
    Condition
      Warning in `esp_dict_translate()`:
      No match found for FFF
      Warning in `esp_dict_region_code()`:
      No match on nuts found for FFF
      Error in `esp_get_prov()`:
      ! `prov = FFF` is not valid.

---

    Code
      esp_get_prov(prov = "Menorca")
    Condition
      Warning in `esp_hlp_all2prov()`:
      Menorca does not return a province
      Error in `esp_get_prov()`:
      ! `prov = Menorca` is not valid.

---

    Code
      esp_get_prov(prov = "ES6x")
    Condition
      Warning in `esp_hlp_all2nuts()`:
      ES6x are not valid nuts codes
      Error in `esp_get_prov()`:
      ! `prov = ES6x` is not valid.

