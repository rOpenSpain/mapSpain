# Testing can bbox

    Code
      esp_get_can_box(style = "ee")
    Condition
      Error:
      ! `style` must be "right", "left", "box", or "poly", not "ee".

---

    Code
      esp_get_can_box(epsg = "ee")
    Condition
      Error:
      ! `epsg` must be "4258", "4326", "3035", or "3857", not "ee".

---

    Code
      esp_get_can_provinces(epsg = "ee")
    Condition
      Error:
      ! `epsg` must be "4258", "4326", "3035", or "3857", not "ee".

