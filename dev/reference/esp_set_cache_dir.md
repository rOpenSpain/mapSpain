# Set your [mapSpain](https://CRAN.R-project.org/package=mapSpain) cache dir

This function will store your `cache_dir` path on your local machine and
would load it for future sessions. Type
`Sys.getenv("MAPSPAIN_CACHE_DIR")` to find your cached path or use
`esp_detect_cache_dir()`.

## Usage

``` r
esp_set_cache_dir(
  cache_dir,
  overwrite = FALSE,
  install = FALSE,
  verbose = TRUE
)

esp_detect_cache_dir()
```

## Arguments

- cache_dir:

  A path to a cache directory. On missing value the function would store
  the cached files on a temporary dir (See
  [`base::tempdir()`](https://rdrr.io/r/base/tempfile.html)).

- overwrite:

  If this is set to `TRUE`, it will overwrite an existing
  `MAPSPAIN_CACHE_DIR` that you already have in local machine.

- install:

  If `TRUE`, will install the key in your local machine for use in
  future sessions. Defaults to `FALSE.` If `cache_dir` is `FALSE` this
  argument is set to `FALSE` automatically.

- verbose:

  logical. If `TRUE` displays informational messages.

## Value

`esp_set_cache_dir()` returns an (invisible) character with the path to
your `cache_dir`, but it is mainly called for its side effect.

`esp_detect_cache_dir()` returns the path to the `cache_dir` used in
this session.

## Details

By default, when no cache `cache_dir` is set the package uses a folder
inside [`base::tempdir()`](https://rdrr.io/r/base/tempfile.html) (so
files are temporary and are removed when the **R** session ends). To
persist a cache across **R** sessions, use
`esp_set_cache_dir(cache_dir, install = TRUE)` which writes the chosen
path to a small configuration file under
`tools::R_user_dir("mapSpain", "config")`.

## Note

In [mapSpain](https://CRAN.R-project.org/package=mapSpain) \>= 1.0.0 the
location of the configuration file has moved from
`rappdirs::user_config_dir("mapSpain", "R")` to
`tools::R_user_dir("mapSpain", "config")`. We have implemented a
functionality that would migrate previous configuration files from one
location to another with a message. This message would appear only once
informing of the migration.

## Caching strategies

Some files can be read from its online source without caching using the
option `cache = FALSE`. Otherwise the source file would be downloaded to
your computer. [mapSpain](https://CRAN.R-project.org/package=mapSpain)
implements the following caching options:

- For occasional use, rely on the default
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)-based cache (no
  install).

- Modify the cache for a single session setting
  `esp_set_cache_dir(cache_dir = "a/path/here)`.

- For reproducible workflows, install a persistent cache with
  `esp_set_cache_dir(cache_dir = "a/path/here, install = TRUE)` that
  would be kept across **R** sessions.

- For caching specific files, use the `cache_dir` argument in the
  corresponding function.

Sometimes cached files may be corrupt. On that case, try re-downloading
the data setting `update_cache = TRUE` in the corresponding function.

If you experience any problem on download, try to download the
corresponding file by any other method and save it on your `cache_dir`.
Use the option `verbose = TRUE` for debugging the API query and
`esp_detect_cache_dir()` to identify your cached path.

## See also

[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)

Other cache utilities:
[`esp_clear_cache()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_clear_cache.md)

## Examples

``` r
# Don't run this! It would modify your current state
# \dontrun{
my_cache <- esp_detect_cache_dir()
#> ℹ C:\Users\RUNNER~1\AppData\Local\Temp\RtmpYNC2jA/mapSpain

# Set an example cache
ex <- file.path(tempdir(), "example", "cachenew")
esp_set_cache_dir(ex)
#> ℹ mapSpain cache dir is C:\Users\RUNNER~1\AppData\Local\Temp\RtmpYNC2jA/example/cachenew.
#> ℹ To install your `cache_dir` path for use in future sessions run this function with `install = TRUE`.

esp_detect_cache_dir()
#> ℹ C:\Users\RUNNER~1\AppData\Local\Temp\RtmpYNC2jA/example/cachenew
#> [1] "C:\\Users\\RUNNER~1\\AppData\\Local\\Temp\\RtmpYNC2jA/example/cachenew"

# Restore initial cache
esp_set_cache_dir(my_cache)
#> ℹ mapSpain cache dir is C:\Users\RUNNER~1\AppData\Local\Temp\RtmpYNC2jA/mapSpain.
#> ℹ To install your `cache_dir` path for use in future sessions run this function with `install = TRUE`.
identical(my_cache, esp_detect_cache_dir())
#> ℹ C:\Users\RUNNER~1\AppData\Local\Temp\RtmpYNC2jA/mapSpain
#> [1] TRUE
# }


esp_detect_cache_dir()
#> ℹ C:\Users\RUNNER~1\AppData\Local\Temp\RtmpYNC2jA/mapSpain
#> [1] "C:\\Users\\RUNNER~1\\AppData\\Local\\Temp\\RtmpYNC2jA/mapSpain"
```
