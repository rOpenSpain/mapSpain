# Clear your [mapSpain](https://CRAN.R-project.org/package=mapSpain) cache dir

**Use this function with caution**. This function would clear your
cached data and configuration, specifically:

- Deletes the [mapSpain](https://CRAN.R-project.org/package=mapSpain)
  config directory (`tools::R_user_dir("mapSpain", "config")`).

- Deletes the `cache_dir` directory.

- Deletes the values on stored on `Sys.getenv("MAPSPAIN_CACHE_DIR")`.

## Usage

``` r
esp_clear_cache(config = FALSE, cached_data = TRUE, verbose = FALSE)
```

## Arguments

- config:

  if `TRUE`, will delete the configuration folder of
  [mapSpain](https://CRAN.R-project.org/package=mapSpain).

- cached_data:

  If this is set to `TRUE`, it will delete your `cache_dir` and all its
  content.

- verbose:

  logical. If `TRUE` displays informational messages.

## Value

Invisible. This function is called for its side effects.

## Details

This is an overkill function that is intended to reset your status as it
you would never have installed and/or used
[mapSpain](https://CRAN.R-project.org/package=mapSpain).

## See also

[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)

Other cache utilities:
[`esp_set_cache_dir()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_set_cache_dir.md)

## Examples

``` r
# Don't run this! It would modify your current state
# \dontrun{
my_cache <- esp_detect_cache_dir()
#> ℹ C:\Users\RUNNER~1\AppData\Local\Temp\RtmpQNViPq/mapSpain

# Set an example cache
ex <- file.path(tempdir(), "example", "cache")
esp_set_cache_dir(ex, verbose = FALSE)

# Restore initial cache
esp_clear_cache(verbose = TRUE)
#> ✔ mapSpain data deleted: C:\Users\RUNNER~1\AppData\Local\Temp\RtmpQNViPq/example/cache (0 bytes)

esp_set_cache_dir(my_cache)
#> ℹ mapSpain cache dir is C:\Users\RUNNER~1\AppData\Local\Temp\RtmpQNViPq/mapSpain.
#> ℹ To install your `cache_dir` path for use in future sessions run this function with `install = TRUE`.
identical(my_cache, esp_detect_cache_dir())
#> ℹ C:\Users\RUNNER~1\AppData\Local\Temp\RtmpQNViPq/mapSpain
#> [1] TRUE
# }
```
