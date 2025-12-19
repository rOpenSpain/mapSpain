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
      esp_dict_region_code(vals, destination = "nuts")
    Output
      [1] "ES23"  "ES111" "ES512" "ES30" 

---

    Code
      esp_dict_region_code(vals, destination = "cpro")
    Output
      [1] "26" "15" "17" "28"

---

    Code
      esp_dict_region_code(vals, destination = "iso2")
    Output
      [1] "ES-RI" "ES-C"  "ES-GI" "ES-MD"

---

    Code
      esp_dict_region_code(c("Región de Murcia", "Principado de Asturias",
        "Ciudad de Ceuta", "Ciudad de Melilla", "Sta. Cruz de Tenerife"),
      destination = "cpro")
    Output
      [1] "30" "33" "51" "52" "38"

---

    Code
      esp_dict_region_code(c("AlBaceTe", "albacete", "ALBACETE"), destination = "cpro")
    Output
      [1] "02" "02" "02"

---

    Code
      esp_dict_region_code(iso2vals, origin = "iso2")
    Output
      [1] "Madrid"    "Cantabria" "Segovia"  

---

    Code
      esp_dict_region_code(valsmix, destination = "nuts")
    Output
      [1] "ES4"   "ES61"  "ES618" "ES533"

---

    Code
      esp_dict_region_code(valsmix, destination = "codauto")
    Message
      ! No match on `destination = "codauto"` found for "Centro", "Seville", and "Menorca".
    Output
      [1] NA   "01" NA   NA  

---

    Code
      esp_dict_region_code(valsmix, destination = "iso2")
    Message
      ! No match on `destination = "iso2"` found for "Centro" and "Menorca".
    Output
      [1] NA      "ES-AN" "ES-SE" NA     

---

    Code
      esp_dict_translate(vals, "xx")
    Condition
      Error:
      ! `lang` should be one of "es", "en", "ca", "ga" or "eu", not "xx".

---

    Code
      esp_dict_translate(c("Ceuta", "Melilla", vals), all = TRUE)
    Output
      $Ceuta
      [1] "Ceuta"           "Ciudad de Ceuta" "ceuta"           "ciudad de ceuta"
      [5] "CEUTA"           "CIUDAD DE CEUTA"
      
      $Melilla
      [1] "Melilla"           "Ciudad de Melilla" "melilla"          
      [4] "ciudad de melilla" "MELILLA"           "CIUDAD DE MELILLA"
      
      $`La Rioja`
      [1] "La Rioja" "la rioja" "LA RIOJA"
      
      $Sevilla
      [1] "Seville" "seville" "SEVILLE"
      
      $Madrid
      [1] "Madrid"                      "madrid"                     
      [3] "MADRID"                      "Madrid Province"            
      [5] "Madrid Autonomous Community" "madrid province"            
      [7] "madrid autonomous community" "MADRID PROVINCE"            
      [9] "MADRID AUTONOMOUS COMMUNITY"
      
      $Jaen
      [1] "Jaén" "Jaen" "jaén" "jaen" "JAÉN" "JAEN"
      
      $Orense
      [1] "Ourense" "ourense" "OURENSE"
      
      $Baleares
      [1] "Balearic Islands" "balearic islands" "BALEARIC ISLANDS" "Balears Province"
      [5] "balears province" "BALEARS PROVINCE"
      

---

    Code
      esp_dict_translate(c(vals, "pepe"))
    Message
      ! No match found for "pepe".
    Output
      [1] "La Rioja"         "Seville"          "Madrid"           "Jaén"            
      [5] "Ourense"          "Balearic Islands" NA                

---

    Code
      esp_dict_translate(c("Región de Murcia", "Principado de Asturias",
        "Ciudad de Ceuta", "Ciudad de Melilla", "Sta. Cruz de Tenerife"), lang = "eu")
    Output
      [1] "Murtzia"                "Asturias"               "Ceuta"                 
      [4] "Melilla"                "Santa Cruz Tenerifekoa"

