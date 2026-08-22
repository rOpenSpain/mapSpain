# esp_get_tiles() rejects unsupported inputs and tile formats

    Code
      esp_get_tiles(df)
    Condition
      Error in `esp_get_tiles()`:
      ! `x` must be an <sf> or <sfc> object, not a data frame.

---

    Code
      esp_get_tiles(ff, type = "IGNBase", options = list(format = "image/aabbcc"))
    Condition
      Error in `esp_get_tiles()`:
      ! The requested file extension must be one of "png", "jpeg", "jpg", "tiff" or "geotiff", not "aabbcc".

# Single WMTS points report automatic zoom only when verbose

    Code
      result <- prepare_tile_geometry(point, NULL, TRUE, "WMTS", TRUE)
    Message
      i Using `zoom` = 18 for a single `POINT` geometry.

# WMTS minimum zoom messages respect verbose

    Code
      verbose_zoom <- resolve_wmts_zoom(NULL, provider, 1, 0, TRUE)
    Message
      i Minimum `zoom` supported by this provider is 4. Increasing `zoom` from 1 to 4.

