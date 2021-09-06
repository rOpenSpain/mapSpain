data("esp_munic.sf")

teruel_cpro <- esp_dict_region_code("Teruel", destination = "cpro")

teruel_sf <- esp_munic.sf[esp_munic.sf$cpro == teruel_cpro, ]
teruel_city <- teruel_sf[teruel_sf$name == "Teruel", ]

# Plot

library(tmap)

tm_shape(teruel_sf) +
  tm_polygons("#FDFBEA") +
  tm_shape(teruel_city) +
  tm_fill(
    col = "name",
    palette = "#C12838",
    labels = "City of Teruel",
    title = ""
  ) +
  tm_graticules(lines = FALSE) +
  tm_layout(
    main.title = "Municipalities of Teruel",
    legend.position = c("left", "top")
  ) +
  tm_scale_bar() +
  tm_compass(
    type = "rose",
    size = 3,
    position = c("left", "bottom")
  )
