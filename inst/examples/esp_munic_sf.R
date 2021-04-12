data("esp_munic.sf")
data("esp_nuts.sf")

Teruel.cpro <- esp_dict_region_code("Teruel", destination = "cpro")
Teruel.NUTS <- esp_dict_region_code(Teruel.cpro,
  origin = "cpro",
  destination = "nuts"
)

Teruel.sf <- esp_munic.sf[esp_munic.sf$cpro == Teruel.cpro, ]
Teruel.city <- Teruel.sf[Teruel.sf$name == "Teruel", ]

# Extract CCAA

CCAA <- esp_get_prov()


library(tmap)

tm_shape(CCAA, bbox = Teruel.sf) +
  tm_polygons("wheat") +
  tm_shape(Teruel.sf) +
  tm_polygons("cornsilk") +
  tm_shape(Teruel.city) +
  tm_fill("firebrick") +
  tm_layout(main.title = "Municipalities of Teruel")
