# tiles error

    Code
      esp_get_tiles(df)
    Condition
      Error in `esp_get_tiles()`:
      ! `x` should be an <sf> or <sfc> object, not a data frame.

---

    Code
      esp_get_tiles(ff, type = "IGNBase", options = list(format = "image/aabbcc"))
    Condition
      Error:
      ! `prov_ext` should be one of "png", "jpeg", "jpg", "tiff" or "geotiff", not "aabbcc".

# WMTS

    Code
      res <- esp_get_tiles(point, "IGNBase", cache_dir = cdir, bbox_expand = 0, crop = TRUE)
    Message
      i Autozoom in single "POINT" set to "18".

