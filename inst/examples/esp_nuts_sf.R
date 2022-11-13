data("esp_nuts.sf")

nuts <- esp_nuts.sf

# Select NUTS 3
nuts3 <- esp_nuts.sf[esp_nuts.sf$LEVL_CODE == 3, ]

# Combine with full shape

spain <- esp_get_country(moveCAN = FALSE)

# Plot Urban Type: See
# https://ec.europa.eu/eurostat/web/rural-development/methodology

library(ggplot2)

nuts3$URBN_TYPE_cat <- as.factor(nuts3$URBN_TYPE)

levels(nuts3$URBN_TYPE_cat)
levels(nuts3$URBN_TYPE_cat) <- c("Urban", "Intermediate", "Rural")

ggplot(nuts3) +
  geom_sf(aes(fill = URBN_TYPE_cat), linewidth = .1) +
  scale_fill_manual(values = c("grey80", "#FFC183", "#68AC20")) +
  labs(
    title = "NUTS3 levels of Spain",
    fill = "Urban topology"
  ) +
  theme_linedraw() +
  theme(
    legend.position = c(.8, .2)
  )
