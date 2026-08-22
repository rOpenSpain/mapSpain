# download_url() returns NULL without creating files while offline

    Code
      fend <- download_url(url, cache_dir = cdir, subdir = "fixme", update_cache = FALSE,
        verbose = FALSE)
    Message
      x No internet connection detected.
      > Returning `NULL`.

