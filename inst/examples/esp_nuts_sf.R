data("esp_nuts.sf")

nuts <- esp_nuts.sf

# Select NUTS 3
nuts3 <- esp_nuts.sf[esp_nuts.sf$LEVL_CODE == 3, ]

# Combine with full shape

spain <- esp_get_country(moveCAN = FALSE)

library(tmap)

# Plot Urban Type: See
# https://ec.europa.eu/eurostat/web/rural-development/methodology
tm_shape(nuts3) +
  tm_polygons(
    "URBN_TYPE",
    style = "cat",
    border.col = "black",
    border.alpha = 0.3,
    title = "Urban topology",
    labels = c("Urban", "Intermediate", "Rural"),
    palette = c("grey80", "#FFC183", "#68AC20")
  ) +
  tm_graticules(lines = FALSE) +
  tm_layout(
    main.title = "NUTS3 levels of Spain",
    legend.position = c("left", "center"),
    legend.title.size = 0.8
  )
