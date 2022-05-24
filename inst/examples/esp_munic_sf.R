data("esp_munic.sf")

teruel_cpro <- esp_dict_region_code("Teruel", destination = "cpro")

teruel_sf <- esp_munic.sf[esp_munic.sf$cpro == teruel_cpro, ]
teruel_city <- teruel_sf[teruel_sf$name == "Teruel", ]

# Plot

library(ggplot2)

ggplot(teruel_sf) +
  geom_sf(fill = "#FDFBEA") +
  geom_sf(data = teruel_city, aes(fill = name)) +
  scale_fill_manual(
    values = "#C12838",
    labels = "City of Teruel"
  ) +
  labs(
    fill = "",
    title = "Municipalities of Teruel"
  ) +
  theme_minimal() +
  theme(
    text = element_text(face = "bold"),
    panel.background = element_rect(colour = "black"),
    panel.grid = element_blank(),
    legend.position = c(.2, .95)
  )
