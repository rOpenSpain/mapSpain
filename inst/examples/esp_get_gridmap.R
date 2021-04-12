library(tmap)

esp <- esp_get_country()
hexccaa <- esp_get_hex_ccaa()


tm_shape(esp, bbox = c(-13.5, 32, 7, 45)) +
  tm_polygons() +
  tm_shape(hexccaa) +
  tm_polygons("codauto", alpha = 0.6, legend.show = FALSE) +
  tm_shape(hexccaa) +
  tm_text("label")



hexprov <- esp_get_hex_prov()

tm_shape(esp, bbox = c(-13.5, 32, 7, 45)) +
  tm_polygons() +
  tm_shape(hexprov) +
  tm_polygons("cpro", alpha = 0.6, legend.show = FALSE) +
  tm_shape(hexprov) +
  tm_text("label")



gridccaa <- esp_get_grid_ccaa()

tm_shape(esp, bbox = c(-13.5, 32, 7, 45)) +
  tm_polygons() +
  tm_shape(gridccaa) +
  tm_polygons("codauto", alpha = 0.6, legend.show = FALSE) +
  tm_shape(gridccaa) +
  tm_text("label")

gridprov <- esp_get_grid_prov()

tm_shape(esp, bbox = c(-13.5, 32, 7, 45)) +
  tm_polygons() +
  tm_shape(gridprov) +
  tm_polygons("cpro", alpha = 0.6, legend.show = FALSE) +
  tm_shape(gridprov) +
  tm_text("label")
