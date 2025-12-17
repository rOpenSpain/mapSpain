# convert_to_nuts

    Code
      n <- convert_to_nuts(NULL)
    Message
      ! Empty `region`. No NUTS codes found, returning NULL.

---

    Code
      n <- convert_to_nuts(NA)
    Message
      ! Empty `region`. No NUTS codes found, returning NULL.

---

    Code
      n <- convert_to_nuts(c(NA, NULL))
    Message
      ! Empty `region`. No NUTS codes found, returning NULL.

---

    Code
      convert_to_nuts(c("Lugo", "Zaporilla", "ES1", "ES-CL"))
    Condition
      Warning in `esp_dict_region_code()`:
      No match on nuts found for Zaporilla
    Output
      [1] "ES112" "ES1"   "ES41" 

---

    Code
      convert_to_nuts(c("Aama", "ES888", "FR12", "ES9"))
    Condition
      Warning in `esp_dict_region_code()`:
      No match on nuts found for Aama
      Warning in `esp_dict_region_code()`:
      No match on nuts found for ES888
      Warning in `esp_dict_region_code()`:
      No match on nuts found for FR12
      Warning in `esp_dict_region_code()`:
      No match on nuts found for ES9
    Message
      ! No Spanish NUTS codes found for "Aama", "ES888", "FR12", and "ES9". Return NULL.
    Output
      NULL

---

    Code
      all
    Output
      [1] "ES6"   "ES21"  "ES120" "ES113" "ES706" "ES24"  "ES614"

