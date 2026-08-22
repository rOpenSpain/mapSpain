# esp_get_grid_ESDAC() rejects invalid resolutions

    Code
      esp_get_grid_ESDAC("50")
    Condition
      Error in `esp_get_grid_ESDAC()`:
      ! `resolution` must be "10" or "1", not "50".

# esp_get_grid_ESDAC() builds the 1 km download request

    Code
      url
    Output
      [1] "https://esdac.jrc.ec.europa.eu/Library/Reference_Grids/Grids/grid_spain_etrs_laea_1k.zip"

