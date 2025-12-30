test_that("Get codes", {
  skip_on_cran()

  names2nuts <- get_master_nuts_nm()

  var <- c(
    # NUTS1
    "Noroeste",
    "Madrid", # Treated as NUTS1 due to higher prelation

    # NUTS2
    "Comunidad Valenciana",
    "Galicia",
    "Murcia", # Treated as NUTS2 due to higher prelation
    "Ceuta", # Treated as NUTS2 due to higher prelation
    "Melilla", # Treated as NUTS2 due to higher prelation
    "Baleares", # Treated as NUTS2 due to higher prelation
    "Las Palmas", # Ignored, no NUTS
    "Santa Cruz de Tenerife", # Ignored, no NUTS
    #  NUTS3
    "Valencia",
    "Segovia",

    # Islands, NUTS3 but not provs

    "Menorca",
    "Tenerife"
  )
  expect_snapshot(var)

  f <- countrycode::countrycode(
    var,
    "key",
    "nuts",
    custom_dict = names2nuts,
    nomatch = "XX"
  )

  expect_snapshot(f)
  expect_false(any(f == "XX"))

  isos <- countrycode::countrycode(
    f,
    "nuts",
    "iso2",
    custom_dict = get_master_codes(),
    nomatch = "XX"
  )

  expect_snapshot(var[!isos == "XX"])
  expect_snapshot(var[isos == "XX"])

  codauto <- countrycode::countrycode(
    f,
    "nuts",
    "codauto",
    custom_dict = get_master_codes(),
    nomatch = "XX"
  )

  expect_snapshot(var[!codauto == "XX"])
  expect_snapshot(var[codauto == "XX"])

  cpro <- countrycode::countrycode(
    f,
    "nuts",
    "cpro",
    custom_dict = get_master_codes(),
    nomatch = "XX"
  )

  expect_snapshot(var[!cpro == "XX"])
  expect_snapshot(var[cpro == "XX"])
})
