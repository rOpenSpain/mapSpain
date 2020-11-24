rm(list = ls())
#options(gisco_cache_dir = "~/R/mapslib/GISCO/")

library(mapSpain)
library(sf)
library(dplyr)
library(ggplot2)


sysfonts::font_add_google("Open Sans")
#sysfonts::font_families_google()


map <- esp_get_munic()
map2 <- esp_get_prov()




a <- ggplot(map) + geom_sf(fill = "#FABD00",
                           colour = "#AD1519",
                           size = 0.05) +
  geom_sf(
    data = map2,
    color = "#FABD00",
    fill = NA,
    lwd = 0.1
  ) +
  theme_void()

#a

library(hexSticker)

# fontinit <- as.character(windowsFonts("serif"))
# windowsFonts(serif = windowsFont("Noto Serif"))




sticker(
  a,
  package = "mapSpain",
  s_width = 2.1,
  s_height = 1.1,
  s_x = 1,
  s_y = 1.1,
  filename = "man/figures/logo.png",
  h_color = "#FABD00",
  h_fill = "#AD1519",
  p_y = 0.45,
   p_family = "Open Sans",
  p_color = "#FABD00",
  white_around_sticker = FALSE,
  #p_size = 15,
 # p_family = "serif",
  p_size = 15
)



# windowsFonts(serif = fontinit)
# windowsFonts("serif")
