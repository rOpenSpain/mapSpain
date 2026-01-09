test_that("Attributions", {
  custom_wmts <- list(
    id = "MadridMapBox",
    q = paste0(
      "https://api.mapbox.com/styles/v1/dieghernan/cmk2cz3wm00ds01sidzuoanfn/",
      "tiles/{z}/{x}/{y}?access_token=A_FAKE_API_KEY"
    )
  )

  expect_snapshot(nn <- esp_get_attributions(custom_wmts))
  expect_null(nn)

  # But
  custom_wmts$attribution <- "\u00a9 Mapbox \u00a9 OpenStreetMap "
  expect_silent(nn_ok <- esp_get_attributions(custom_wmts))
  expect_identical(nn_ok, custom_wmts$attribution)

  # Built-in
  att <- esp_get_attributions("PNOA")
  expect_identical(att, esp_tiles_providers[["PNOA"]]$static$attribution)
})
