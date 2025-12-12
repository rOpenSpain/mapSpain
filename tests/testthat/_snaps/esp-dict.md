# Testing dict

    Code
      esp_dict_region_code(vals, "aa")
    Condition
      Error:
      ! `origin` should be one of "text", "nuts", "iso2", "codauto" or "cpro", not "aa".

---

    Code
      esp_dict_region_code(vals, destination = "aa")
    Condition
      Error:
      ! `destination` should be one of "text", "nuts", "iso2", "codauto" or "cpro", not "aa".

---

    Code
      esp_dict_region_code(vals)
    Message
      i No conversion. `origin` equal to `destination` ("text")
    Output
      [1] "Errioxa" "Coruna"  "Gerona"  "Madrid" 

---

    Code
      esp_dict_translate(vals, "xx")
    Condition
      Error:
      ! `lang` should be one of "es", "en", "ca", "ga" or "eu", not "xx".

