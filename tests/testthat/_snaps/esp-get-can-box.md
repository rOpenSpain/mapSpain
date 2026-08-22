# Canary inset helpers validate options and move geometries

    Code
      esp_get_can_box(style = "ee")
    Condition
      Error in `esp_get_can_box()`:
      ! `style` must be "right", "left", "box" or "poly", not "ee".

---

    Code
      esp_get_can_box(epsg = "ee")
    Condition
      Error in `esp_get_can_box()`:
      ! `epsg` must be "4258", "4326", "3035" or "3857", not "ee".

---

    Code
      esp_get_can_provinces(epsg = "ee")
    Condition
      Error in `esp_get_can_provinces()`:
      ! `epsg` must be "4258", "4326", "3035" or "3857", not "ee".

