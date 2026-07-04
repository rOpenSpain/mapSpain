# Mock migration

    Code
      detected <- detect_cache_dir_muted()
    Message
      v Migrated the cache configuration for mapSpain "1.0.0" and later.See Note in `mapSpain::esp_set_cache_dir()` for details.
      i This is a one-time message. It will not be displayed again.

# Mock write_installed_cache_dir

    Code
      write_installed_cache_dir("another")
    Condition
      Error in `write_installed_cache_dir()`:
      ! A path is already configured for `cache_dir`.
      i Set `overwrite` to "TRUE" to replace it.

