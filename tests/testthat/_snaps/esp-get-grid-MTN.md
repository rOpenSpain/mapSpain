# esp_get_grid_MTN() rejects unknown grids

    Code
      esp_get_grid_MTN("abcde")
    Condition
      Error in `esp_get_grid_MTN()`:
      ! `grid` must be "MTN25_ED50_Peninsula_Baleares", "MTN25_ETRS89_ceuta_melilla_alboran", "MTN25_ETRS89_Peninsula_Baleares_Canarias", "MTN25_RegCan95_Canarias", "MTN50_ED50_Peninsula_Baleares", "MTN50_ETRS89_Peninsula_Baleares_Canarias" or "MTN50_RegCan95_Canarias", not "abcde".

