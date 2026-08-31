test_that("esp_timeout() reads valid environment values and uses defaults", {
  withr::local_options(list(mapspain_timeout = NULL))
  withr::local_envvar(c(MAPSPAIN_TIMEOUT = "600"))

  expect_equal(esp_timeout(), 600)

  withr::local_envvar(c(MAPSPAIN_TIMEOUT = NA))
  expect_equal(esp_timeout(), 300L)

  withr::local_envvar(c(MAPSPAIN_TIMEOUT = "invalid"))
  expect_equal(esp_timeout(), 300L)
})

test_that("esp_timeout() gives package options precedence over environment", {
  withr::local_options(list(mapspain_timeout = 30))
  withr::local_envvar(c(MAPSPAIN_TIMEOUT = "600"))

  expect_equal(esp_timeout(), 30)
})

test_that("download_url() applies the configured HTTP timeout", {
  withr::local_options(list(mapspain_timeout = NULL))
  withr::local_envvar(c(MAPSPAIN_TIMEOUT = "600"))

  seen <- list()
  local_mocked_bindings(
    is_online_fun = function(...) TRUE,
    esp_req_perform = function(req, path = NULL, ...) {
      seen[[length(seen) + 1]] <<- req$options
      if (is.null(path)) {
        return(httr2::response(
          status_code = 200,
          headers = list("content-length" = "2")
        ))
      }

      writeLines("ok", path)
      httr2::response(status_code = 200)
    }
  )

  cdir <- withr::local_tempdir(pattern = "testthat_envvar")
  out <- download_url(
    "https://example.com/envvar.txt",
    cache_dir = cdir,
    verbose = FALSE
  )

  expect_type(out, "character")
  expect_equal(seen[[1]]$timeout_ms, 600000)
})

test_that("download_url() returns NULL without creating files while offline", {
  skip_on_cran()
  skip_if_siane_offline()
  local_mocked_bindings(is_online_fun = function(...) {
    FALSE
  })

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_y.gpkg"
  )
  cdir <- withr::local_tempdir(pattern = "testthat-ex-")
  expect_snapshot(
    fend <- download_url(
      url,
      cache_dir = cdir,
      subdir = "fixme",
      update_cache = FALSE,
      verbose = FALSE
    )
  )
  expect_null(fend)
  expect_length(list.files(cdir, recursive = TRUE), 0)
  unlink(cdir, recursive = TRUE, force = TRUE)

  local_mocked_bindings(is_online_fun = function(...) {
    httr2::is_online()
  })
})

test_that("download_url() returns NULL for HTTP 404 and downloads valid URLs", {
  skip_on_cran()
  skip_if_siane_offline()

  cdir <- withr::local_tempdir(pattern = "testthat-ex-")
  local_mocked_bindings(is_404 = function(...) {
    TRUE
  })
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_y.gpkg"
  )
  expect_message(
    s <- download_url(
      url,
      verbose = FALSE,
      cache_dir = cdir,
      update_cache = TRUE
    ),
    "HTTP error"
  )
  expect_null(s)

  local_mocked_bindings(is_404 = function(...) {
    FALSE
  })

  # Otherwise work
  expect_silent(
    s <- download_url(
      url,
      verbose = FALSE,
      cache_dir = cdir,
      update_cache = TRUE
    )
  )
  expect_length(s, 1)
  expect_type(s, "character")
})

test_that("download_url() reuses and refreshes cached files", {
  skip_on_cran()
  skip_if_siane_offline()

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_urban_capimuni_p_y.gpkg"
  )
  cdir <- withr::local_tempdir(pattern = "testthat-ex-")
  expect_message(
    fend <- download_url(
      url,
      cache_dir = cdir,
      subdir = "fixme",
      update_cache = FALSE,
      verbose = TRUE
    ),
    "Cache directory is"
  )

  expect_length(list.files(cdir, recursive = TRUE), 1)

  expect_message(
    fend <- download_url(
      url,
      cache_dir = cdir,
      subdir = "fixme",
      update_cache = FALSE,
      verbose = TRUE
    ),
    "File already"
  )

  expect_message(
    fend <- download_url(
      url,
      cache_dir = cdir,
      subdir = "fixme",
      update_cache = TRUE,
      verbose = TRUE
    ),
    "Updating cached"
  )

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("download_url() reports failures and large downloads", {
  skip_on_cran()
  skip_if_siane_offline()

  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "fake-file.txt"
  )
  cdir <- withr::local_tempdir(pattern = "testthat-ex-")
  expect_message(
    fend <- download_url(
      url,
      cache_dir = cdir,
      subdir = "fixme",
      update_cache = FALSE,
      verbose = FALSE
    ),
    "HTTP error"
  )

  expect_null(fend)

  # Warn if size of download is huge

  url <- paste0(
    "https://gisco-services.ec.europa.eu/distribution/v2/",
    "lau/gpkg/LAU_RG_01M_2024_4326.gpkg"
  )

  expect_message(
    download_url(
      url,
      cache_dir = cdir,
      subdir = "fixme",
      update_cache = FALSE,
      verbose = FALSE
    ),
    "Download size"
  )

  unlink(cdir, recursive = TRUE, force = TRUE)
})

test_that("for_import_jsonlite() loads jsonlite without returning a value", {
  skip_on_cran()
  skip_if_siane_offline()
  expect_silent(p <- for_import_jsonlite())
  expect_null(for_import_jsonlite())
})

test_that("download_url() surfaces timeouts and recovers with valid settings", {
  skip_on_cran()
  skip_if_siane_offline()
  skip_on_os("linux")

  cdir <- withr::local_tempdir(pattern = "testthat-timeout-")
  url <- paste0(
    "https://github.com/rOpenSpain/mapSpain/raw/sianedata/dist/",
    "se89_3_admin_muni_a_x.gpkg"
  )

  withr::local_options(c(mapspain_timeout = 0.001))
  expect_error(
    download_url(url = url, verbose = FALSE, cache_dir = cdir),
    "Failed to perform HTTP request(.*)Timeout",
    class = "httr2_failure"
  )

  withr::local_options(c(mapspain_timeout = 300L))
  expect_silent(
    ff <- download_url(url = url, verbose = FALSE, cache_dir = cdir)
  )

  expect_true(file.exists(ff))
  unlink(cdir, recursive = TRUE, force = TRUE)
  expect_false(file.exists(ff))
})
