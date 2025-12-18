# CCAA

    Code
      esp_get_ccaa("FFF")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish CCAA codes found for "FFF".

---

    Code
      n <- esp_get_ccaa(c("FFF", "Murcia"))
    Message
      ! No Spanish CCAA codes found for "FFF".

---

    Code
      esp_get_ccaa(ccaa = "Zamora")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish CCAA codes found for "Zamora".

---

    Code
      esp_get_ccaa(ccaa = "ES6x")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish CCAA codes found for "ES6x".

