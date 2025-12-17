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
    Message
      ! No match on `destination = "nuts"` found for "Zaporilla".
    Output
      [1] "ES1"   "ES112" "ES41" 

---

    Code
      convert_to_nuts(c("Aama", "ES888", "FR12", "ES9"))
    Message
      ! No match on `destination = "nuts"` found for "Aama".
      ! No match on `destination = "nuts"` found for "ES888".
      ! No match on `destination = "nuts"` found for "FR12".
      ! No match on `destination = "nuts"` found for "ES9".
      ! No Spanish NUTS codes found for "Aama", "ES888", "FR12", and "ES9". Return NULL.
    Output
      NULL

---

    Code
      all
    Output
      [1] "ES113" "ES120" "ES21"  "ES24"  "ES6"   "ES614" "ES706"

---

    Code
      esp_dict_region_code(all, origin = "nuts", destination = "text")
    Output
      [1] "Ourense"    "Asturias"   "País Vasco" "Aragón"     "SUR"       
      [6] "Granada"    "La Gomera" 

# convert_to_nuts_ccaa

    Code
      n <- convert_to_nuts_ccaa(NULL)
    Message
      ! Empty `region`. No CCAA codes found, returning NULL.

---

    Code
      n <- convert_to_nuts_ccaa(NA)
    Message
      ! Empty `region`. No CCAA codes found, returning NULL.

---

    Code
      n <- convert_to_nuts_ccaa(c(NA, NULL))
    Message
      ! Empty `region`. No CCAA codes found, returning NULL.

---

    Code
      convert_to_nuts_ccaa(c("Asturies", "Zaporilla", "ES1", "ES-CL"))
    Message
      ! No match on `destination = "nuts"` found for "Zaporilla".
      ! No Spanish NUTS codes found for "Zaporilla". Return NULL.
    Output
      [1] "ES11" "ES12" "ES13" "ES41"

---

    Code
      convert_to_nuts(c("Aama", "ES888", "FR12", "ES9"))
    Message
      ! No match on `destination = "nuts"` found for "Aama".
      ! No match on `destination = "nuts"` found for "ES888".
      ! No match on `destination = "nuts"` found for "FR12".
      ! No match on `destination = "nuts"` found for "ES9".
      ! No Spanish NUTS codes found for "Aama", "ES888", "FR12", and "ES9". Return NULL.
    Output
      NULL

---

    Code
      all
    Output
      [1] "ES11" "ES12" "ES13" "ES21" "ES43" "ES63" "ES64" "ES70"

---

    Code
      esp_dict_region_code(all, origin = "nuts", destination = "text")
    Output
      [1] "Galicia"                    "Principado de Asturias"    
      [3] "Cantabria"                  "País Vasco"                
      [5] "Extremadura"                "Ciudad Autónoma de Ceuta"  
      [7] "Ciudad Autónoma de Melilla" "Canarias"                  

---

    Code
      convert_to_nuts_ccaa(c("Murcia", "Almeria"))
    Message
      ! "Almeria" does not return a Autonomous Community.
    Output
      [1] "ES62"

---

    Code
      is_null <- convert_to_nuts_ccaa(c("La Gomera", "Almeria", "Soria"))
    Message
      ! "La Gomera", "Almeria", and "Soria" do not return a Autonomous Community.
      ! No Spanish CCAA codes found for "La Gomera", "Almeria", and "Soria". Return NULL.

---

    Code
      is_null <- convert_to_nuts_ccaa(c("AA", "XX"))
    Message
      ! No match on `destination = "nuts"` found for "AA".
      ! No Spanish NUTS codes found for "AA". Return NULL.
      ! No match on `destination = "nuts"` found for "XX".
      ! No Spanish NUTS codes found for "XX". Return NULL.

