nuts <- esp_nuts.sf

# Select NUTS 3
nuts3 <- esp_nuts.sf[esp_nuts.sf$LEVL_CODE == 3, ]

# Combine with full shape

spain <- esp_get_country(moveCAN = FALSE)

library(tmap)

tm_shape(nuts3) +
  tm_fill(
    "URBN_TYPE",
    style = "cat",
    title = "Urban Type",
    palette = hcl.colors(3, "Teal")
  ) +
  tm_shape(spain) +
  tm_borders(col = "black") +
  tm_graticules(lines = FALSE) +
  tm_layout(
    main.title = "NUTS3 levels of Spain",
    legend.outside = TRUE
  )
