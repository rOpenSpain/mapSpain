# Mock migration

    Code
      detected <- detect_cache_dir_muted()
    Message
      v mapSpain >= "1.0.0": cache configuration migrated.See Note in `mapSpain::esp_set_cache_dir()` for details.
      i This is a one-time message. It will not be displayed again.

# Mock write_installed_cache_dir

    Code
      write_installed_cache_dir("another")
    Condition
      Error in `write_installed_cache_dir()`:
      ! A `cache_dir` path already exists.
      You can overwrite it with `overwrite` set to TRUE.

