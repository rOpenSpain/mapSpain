# esp_get_ccaa() validates and filters autonomous communities

    Code
      esp_get_ccaa("FFF")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish Autonomous Communities and Cities codes found for "FFF".

---

    Code
      n <- esp_get_ccaa(c("FFF", "Murcia"))
    Condition
      Warning:
      No Spanish Autonomous Communities and Cities codes found for "FFF".

---

    Code
      esp_get_ccaa(ccaa = "Zamora")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish Autonomous Communities and Cities codes found for "Zamora".

---

    Code
      esp_get_ccaa(ccaa = "ES6x")
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish Autonomous Communities and Cities codes found for "ES6x".

