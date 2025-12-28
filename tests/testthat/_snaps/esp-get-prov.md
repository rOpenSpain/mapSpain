# prov offline

    Code
      esp_get_prov(prov = "FFF")
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "FFF".

---

    Code
      esp_get_prov(prov = "Menorca")
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "Menorca".

---

    Code
      esp_get_prov(prov = "ES6x")
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "ES6x".

---

    Code
      mix$ine.prov.name
    Output
       [1] "Barcelona"          "Girona"             "Lleida"            
       [4] "Tarragona"          "Alicante/Alacant"   "Castellón/Castelló"
       [7] "Valencia/València"  "Badajoz"            "Cáceres"           
      [10] "Araba/Álava"        "Gipuzkoa"           "Bizkaia"           

---

    Code
      islands$ine.prov.name
    Output
      [1] "Balears, Illes"         "Palmas, Las"            "Santa Cruz de Tenerife"

---

    Code
      n2 <- esp_get_prov(prov = c(f$cpro, "La Gomera"))
    Message
      ! No Spanish province codes found for "La Gomera".

