# CCAA

    Code
      esp_get_ccaa("FFF")
    Message
      ! No Spanish CCAA codes found for "FFF".
    Condition
      Error in `esp_get_ccaa()`:
      ! Can't provide CCAA <sf> objects for "FFF".

---

    Code
      n <- esp_get_ccaa(c("FFF", "Murcia"))
    Message
      ! No Spanish CCAA codes found for "FFF".

---

    Code
      esp_get_ccaa(ccaa = "Zamora")
    Message
      ! No Spanish CCAA codes found for "Zamora".
    Condition
      Error in `esp_get_ccaa()`:
      ! Can't provide CCAA <sf> objects for "Zamora".

---

    Code
      esp_get_ccaa(ccaa = "ES6x")
    Message
      ! No Spanish CCAA codes found for "ES6x".
    Condition
      Error in `esp_get_ccaa()`:
      ! Can't provide CCAA <sf> objects for "ES6x".

