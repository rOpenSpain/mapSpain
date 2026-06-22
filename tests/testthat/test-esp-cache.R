test_that("Test cache", {
  # Get current cache dir
  expect_message(current <- esp_detect_cache_dir())

  # Set a temp cache dir
  expect_message(esp_set_cache_dir(verbose = TRUE))
  testdir <- expect_silent(esp_set_cache_dir(
    file.path(current, "testthat"),
    verbose = FALSE
  ))

  expect_identical(esp_detect_cache_dir(), testdir)

  # Clean
  expect_silent(esp_clear_cache(config = FALSE, verbose = FALSE))
  # Cache dir should be deleted now
  expect_false(dir.exists(testdir))

  # Reset just for testing all cases
  testdir <- file.path(tempdir(), "mapspain", "testthat")
  expect_message(esp_set_cache_dir(testdir))

  expect_true(dir.exists(testdir))

  expect_message(esp_clear_cache(config = FALSE, verbose = TRUE))

  # Cache dir should be deleted now
  expect_false(dir.exists(testdir))

  # Restore cache
  expect_message(esp_set_cache_dir(current, verbose = TRUE))
  expect_silent(esp_set_cache_dir(current, verbose = FALSE))
  expect_equal(current, Sys.getenv("MAPSPAIN_CACHE_DIR"))
  expect_true(dir.exists(current))
})

test_that("Mock restart", {
  skip_on_cran()

  # Careful!
  cache_config <- file.path(
    tools::R_user_dir("mapSpain", "config"),
    "mapSpain_cache_dir"
  )

  tester_has_config_installed <- file.exists(cache_config)

  if (tester_has_config_installed) {
    stored_val <- readLines(cache_config, warn = FALSE)

    withr::defer({
      esp_set_cache_dir(
        stored_val,
        install = TRUE,
        overwrite = TRUE,
        verbose = FALSE
      )
    })
  }

  withr::local_envvar(c(MAPSPAIN_CACHE_DIR = NA))

  expect_identical(Sys.getenv("MAPSPAIN_CACHE_DIR"), "")

  if (tester_has_config_installed) {
    esp_clear_cache(cached_data = FALSE, config = TRUE)
    expect_false(file.exists(cache_config))
    expect_false(nzchar(Sys.getenv("MAPSPAIN_CACHE_DIR")))

    # We are clear now, we should detect default cache location
    default_loc <- detect_cache_dir_muted()

    # Should be the tempdir
    expect_identical(file.path(tempdir(), "mapSpain"), default_loc)

    # Now we should restore the cache
    expect_message(
      esp_set_cache_dir(stored_val, overwrite = TRUE, install = TRUE),
      "cache directory is"
    )

    # But for the next test we delete the envar
    Sys.unsetenv("MAPSPAIN_CACHE_DIR")
    expect_identical(Sys.getenv("MAPSPAIN_CACHE_DIR"), "")
  }

  muted <- detect_cache_dir_muted()
  created <- create_cache_dir()
  muted2 <- detect_cache_dir_muted()

  expect_identical(muted, created)
  expect_identical(muted, muted2)
  expect_true(nzchar(Sys.getenv("MAPSPAIN_CACHE_DIR")))
})

test_that("Mock migration", {
  skip_on_cran()

  withr::local_envvar(c(MAPSPAIN_CACHE_DIR = NA))

  old <- rappdirs::user_config_dir("mapSpain", "R")
  new <- tools::R_user_dir("mapSpain", "config")
  fname <- "mapSpain_cache_dir"

  old_fname <- file.path(old, fname)
  new_fname <- file.path(new, fname)

  old_exists <- file.exists(old_fname)
  new_exists <- file.exists(new_fname)

  old_val <- if (old_exists) readLines(old_fname, warn = FALSE) else NULL
  new_val <- if (new_exists) readLines(new_fname, warn = FALSE) else NULL

  withr::defer({
    unlink(old_fname)
    unlink(new_fname)

    if (old_exists) {
      dir.create(dirname(old_fname), recursive = TRUE, showWarnings = FALSE)
      writeLines(old_val, old_fname)
    }

    if (new_exists) {
      dir.create(dirname(new_fname), recursive = TRUE, showWarnings = FALSE)
      writeLines(new_val, new_fname)
    }
  })

  expect_identical(Sys.getenv("MAPSPAIN_CACHE_DIR"), "")

  unlink(old_fname)
  unlink(new_fname)

  expect_false(file.exists(old_fname))
  expect_false(file.exists(new_fname))

  create_cache_dir(old)
  writeLines(tempdir(), old_fname)
  expect_true(file.exists(old_fname))

  expect_snapshot(detected <- detect_cache_dir_muted())

  expect_silent(detected2 <- detect_cache_dir_muted())

  expect_identical(detected, detected2)
  expect_identical(detected, tempdir())
  expect_identical(Sys.getenv("MAPSPAIN_CACHE_DIR"), detected)

  expect_false(file.exists(old_fname))
  expect_true(file.exists(new_fname))
})
test_that("Test cache online", {
  # Get current cache dir
  current <- esp_detect_cache_dir()

  # Set a temp cache dir
  expect_message(esp_set_cache_dir(verbose = TRUE))
  testdir <- expect_silent(esp_set_cache_dir(
    file.path(current, "testthat"),
    verbose = FALSE
  ))

  expect_identical(esp_detect_cache_dir(), testdir)

  # Clean
  expect_silent(esp_clear_cache(config = FALSE, verbose = FALSE))
  # Cache dir should be deleted now
  expect_false(dir.exists(testdir))

  # Reset just for testing all cases
  testdir <- file.path(tempdir(), "mapSpain", "testthat")
  expect_message(esp_set_cache_dir(testdir))

  skip_on_cran()
  skip_if_siane_offline()

  expect_message(esp_get_ccaa_siane(verbose = TRUE))

  expect_true(dir.exists(testdir))

  expect_message(esp_clear_cache(config = FALSE, verbose = TRUE))

  # Cache dir should be deleted now
  expect_false(dir.exists(testdir))

  # Restore cache
  expect_message(esp_set_cache_dir(current, verbose = TRUE))
  expect_silent(esp_set_cache_dir(current, verbose = FALSE))
  expect_equal(current, Sys.getenv("MAPSPAIN_CACHE_DIR"))
  expect_true(dir.exists(current))
})

test_that("Mock write_installed_cache_dir", {
  mock_mapesp_file <- tempfile()
  mock_config_dir <- file.path(tempdir(), "a_test")
  expect_false(file.exists(mock_mapesp_file))
  local_mocked_bindings(
    cache_config_dir = function(...) {
      mock_config_dir
    },
    cache_config_file = function(...) {
      mock_mapesp_file
    }
  )
  write_installed_cache_dir("aabbcc")
  expect_equal(readLines(mock_mapesp_file), "aabbcc")

  expect_snapshot(error = TRUE, write_installed_cache_dir("another"))
  expect_silent(write_installed_cache_dir("another", overwrite = TRUE))
  expect_equal(readLines(mock_mapesp_file), "another")
  unlink(mock_config_dir, recursive = TRUE, force = TRUE)
  unlink(mock_mapesp_file, force = TRUE)
})
test_that("Mock installing", {
  initial_cdir <- esp_detect_cache_dir()
  tdir <- file.path(tempdir(), "created_for_tests")

  local_mocked_bindings(
    create_cache_dir = function(...) {
      # Bypass create_cache_dir
      esp_detect_cache_dir()
    },
    write_installed_cache_dir = function(cache_dir, overwrite) {
      expect_false(overwrite)
      expect_identical(cache_dir, initial_cdir)
      NULL
    }
  )

  esp_set_cache_dir(tdir, install = TRUE, verbose = FALSE)
  # Ensure nothing changed
  expect_identical(initial_cdir, esp_detect_cache_dir())
})

test_that("Mock reading file", {
  skip_on_cran()
  local_mocked_bindings(
    cache_config_file = function() {
      "aaaaaaaaa"
    }
  )

  expect_null(read_installed_cache_dir())

  tmpfile <- tempfile()
  writeLines("", tmpfile)
  local_mocked_bindings(
    cache_config_file = function() {
      tmpfile
    }
  )
  expect_null(read_installed_cache_dir())

  writeLines("a_test_here", tmpfile)
  local_mocked_bindings(
    cache_config_file = function() {
      tmpfile
    }
  )
  expect_identical(read_installed_cache_dir(), "a_test_here")
})
test_that("Mock detect muted", {
  mock_path <- file.path(tempdir(), "testing")
  withr::local_envvar(
    c(MAPSPAIN_CACHE_DIR = NA)
  )
  Sys.getenv("MAPSPAIN_CACHE_DIR")
  local_mocked_bindings(
    read_installed_cache_dir = function(...) {
      mock_path
    }
  )

  expect_identical(detect_cache_dir_muted(), mock_path)
  unlink(mock_path)
})
