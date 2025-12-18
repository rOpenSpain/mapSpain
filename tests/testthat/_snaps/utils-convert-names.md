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
      ! No Spanish NUTS codes found for "Zaporilla".
    Output
      [1] "ES1"   "ES112" "ES41" 

---

    Code
      convert_to_nuts(c("Aama", "ES888", "FR12", "ES9"))
    Message
      ! No Spanish NUTS codes found for "Aama", "ES888", "FR12", and "ES9".
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
      convert_to_nuts_ccaa(c("Asturies", "Zaporilla", "ES1", "ES-CL"))
    Message
      ! No Spanish CCAA codes found for "Zaporilla".
    Output
      [1] "ES11" "ES12" "ES13" "ES41"

---

    Code
      convert_to_nuts_ccaa(c("Aama", "ES888", "FR12", "ES9"))
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish CCAA codes found for "Aama", "ES888", "FR12", and "ES9".

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
      ! No Spanish CCAA codes found for "Almeria".
    Output
      [1] "ES62"

---

    Code
      convert_to_nuts_ccaa(c("La Gomera", "Almeria", "Soria"))
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish CCAA codes found for "La Gomera", "Almeria", and "Soria".

---

    Code
      convert_to_nuts_ccaa(c("AA", "XX"))
    Condition
      Error in `convert_to_nuts_ccaa()`:
      ! No Spanish CCAA codes found for "AA" and "XX".

# convert_to_nuts_prov

    Code
      n <- convert_to_nuts_prov(NULL)

---

    Code
      n <- convert_to_nuts_prov(NA)

---

    Code
      n <- convert_to_nuts_prov(c(NA, NULL))

---

    Code
      convert_to_nuts_prov(c("Asturies", "Zaporilla", "Euskadi", "Madrid"))
    Message
      ! No Spanish province codes found for "Zaporilla".
    Output
      [1] "ES120" "ES211" "ES212" "ES213" "ES300"

---

    Code
      convert_to_nuts_prov(c("Aama", "ES888", "FR12", "ES9"))
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "Aama", "ES888", "FR12", and "ES9".

---

    Code
      all
    Output
       [1] "ES211" "ES212" "ES213" "ES411" "ES416" "ES431" "ES432" "ES531" "ES532"
      [10] "ES533" "ES620" "ES630" "ES640" "ES703" "ES704" "ES705" "ES706" "ES707"
      [19] "ES708" "ES709"

---

    Code
      esp_dict_region_code(all, origin = "nuts", destination = "text")
    Output
       [1] "Araba/Álava"          "Gipuzkoa"             "Bizkaia"             
       [4] "Ávila"                "Segovia"              "Badajoz"             
       [7] "Cáceres"              "Eivissa y Formentera" "Mallorca"            
      [10] "Menorca"              "Murcia"               "Ceuta"               
      [13] "Melilla"              "El Hierro"            "Fuerteventura"       
      [16] "Gran Canaria"         "La Gomera"            "La Palma"            
      [19] "Lanzarote"            "Tenerife"            

---

    Code
      convert_to_nuts_prov(c("Murcia", "Almeria"))
    Output
      [1] "ES611" "ES620"

---

    Code
      convert_to_nuts_prov(c("La Gomera", "El Hierro", "Formentera", "Mallorca"))
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "La Gomera", "El Hierro", "Formentera", and "Mallorca".

---

    Code
      convert_to_nuts_prov(c("AA", "XX"))
    Condition
      Error in `convert_to_nuts_prov()`:
      ! No Spanish province codes found for "AA" and "XX".

---

    Code
      n <- convert_to_nuts_prov(nm)
    Message
      ! No Spanish province codes found for "Eivissa y Formentera", "Mallorca", "Menorca", "Fuerteventura", "Gran Canaria", "Lanzarote", "El Hierro", "La Gomera", "La Palma", and "Tenerife".

