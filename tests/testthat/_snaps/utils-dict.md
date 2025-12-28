# Get codes

    Code
      var
    Output
       [1] "Noroeste"               "Madrid"                 "Comunidad Valenciana"  
       [4] "Galicia"                "Murcia"                 "Ceuta"                 
       [7] "Melilla"                "Baleares"               "Las Palmas"            
      [10] "Santa Cruz de Tenerife" "Valencia"               "Segovia"               
      [13] "Menorca"                "Tenerife"              

---

    Code
      f
    Output
       [1] "ES1"   "ES3"   "ES52"  "ES11"  "ES62"  "ES63"  "ES64"  "ES53"  "XXXXX"
      [10] "YYYYY" "ES523" "ES416" "ES533" "ES709"

---

    Code
      var[!isos == "XX"]
    Output
      [1] "Comunidad Valenciana"   "Galicia"                "Murcia"                
      [4] "Baleares"               "Las Palmas"             "Santa Cruz de Tenerife"
      [7] "Valencia"               "Segovia"               

---

    Code
      var[isos == "XX"]
    Output
      [1] "Noroeste" "Madrid"   "Ceuta"    "Melilla"  "Menorca"  "Tenerife"

---

    Code
      var[!codauto == "XX"]
    Output
      [1] "Comunidad Valenciana" "Galicia"              "Murcia"              
      [4] "Ceuta"                "Melilla"              "Baleares"            

---

    Code
      var[codauto == "XX"]
    Output
      [1] "Noroeste"               "Madrid"                 "Las Palmas"            
      [4] "Santa Cruz de Tenerife" "Valencia"               "Segovia"               
      [7] "Menorca"                "Tenerife"              

---

    Code
      var[!cpro == "XX"]
    Output
      [1] "Las Palmas"             "Santa Cruz de Tenerife" "Valencia"              
      [4] "Segovia"               

---

    Code
      var[cpro == "XX"]
    Output
       [1] "Noroeste"             "Madrid"               "Comunidad Valenciana"
       [4] "Galicia"              "Murcia"               "Ceuta"               
       [7] "Melilla"              "Baleares"             "Menorca"             
      [10] "Tenerife"            

