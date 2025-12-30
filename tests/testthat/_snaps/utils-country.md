# Utils names

    Code
      convert_country_code(c("Espagne", "United Kingdom"))
    Output
      [1] "ESP" "GBR"

---

    Code
      convert_country_code("U")
    Condition
      Error:
      ! Invalid country name "U". Try a vector of names or ISO3/ISO2 codes

---

    Code
      convert_country_code(c("ESP", "POR", "RTA", "USA"), "iso3c")
    Message
      ! Some country/codes were not matched unambiguously: "POR" and "RTA"
      i Review the names/codes or switch to ISO3 codes.
    Output
      [1] "ESP" "USA"

---

    Code
      convert_country_code(c("ESP", "Alemania"))
    Output
      [1] "ESP" "DEU"

# Problematic names

    Code
      convert_country_code(c("Espagne", "Antartica"))
    Output
      [1] "ESP" "ATA"

---

    Code
      convert_country_code(c("spain", "antartica"))
    Output
      [1] "ESP" "ATA"

---

    Code
      convert_country_code(c("Spain", "Kosovo", "Antartica"))
    Output
      [1] "ESP" "XKX" "ATA"

---

    Code
      convert_country_code(c("Spain", "Kosovo", "Antartica"), "iso3c")
    Output
      [1] "ESP" "XKX" "ATA"

---

    Code
      convert_country_code(c("ESP", "XKX", "DEU"))
    Output
      [1] "ESP" "XKX" "DEU"

---

    Code
      convert_country_code(c("Spain", "Rea", "Kosovo", "Antartica", "Murcua"))
    Message
      ! Some country/codes were not matched unambiguously: "Rea" and "Murcua"
      i Review the names/codes or switch to ISO3 codes.
    Output
      [1] "ESP" "XKX" "ATA"

---

    Code
      convert_country_code("Kosovo")
    Output
      [1] "XKX"

---

    Code
      convert_country_code("XKX")
    Output
      [1] "XKX"

---

    Code
      convert_country_code("XK", "iso3c")
    Output
      [1] "XKX"

# Test mixed countries

    Code
      convert_country_code(c("Germany", "USA", "Greece", "united Kingdom"))
    Output
      [1] "DEU" "USA" "GRC" "GBR"

