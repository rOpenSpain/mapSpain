# spanishoddata (0.2.1)

* GitHub: <https://github.com/rOpenSpain/spanishoddata>
* Email: <mailto:kotov.egor@gmail.com>
* GitHub mirror: <https://github.com/cran/spanishoddata>

Run `revdepcheck::revdep_details(, "spanishoddata")` for more info

## In both

*   checking running R code from vignettes ...
     ```
     ...
     Errors in running code in vignettes:
     when running code in 'convert.qmd'
       ...
     > spod_download(type = "od", zones = "distr", dates = dates_1)
     Aviso en spod_get_data_dir() :
       Warning: SPANISH_OD_DATA_DIR is not set. Using the temporary directory, which is not recommended, as the data will be deleted when the session ends.
     
      To set the data directory, use `spod_set_data_dir('/path/to/data')` or set SPANISH_OD_DATA_DIR permanently in the environment by editing the `.Renviron` file locally for current project with `usethis::edit_r_environ('project')` or `file.edit('.Renviron')` or globally for all projects with `usethis::edit_r_environ('user')` or `file.edit('~/.Renviron')`.
     Aviso:  1 failed to parse.
     
       When sourcing 'convert.R':
     Error: valor ausente donde TRUE/FALSE es necesario
     Ejecución interrumpida
     when running code in 'quick-get.qmd'
       ...
     
     
     > library(stringr)
     
     > od_1000 <- spod_quick_get_od(date = "2022-01-01", 
     +     min_trips = 1000)
     
       When sourcing 'quick-get.R':
     Error: No data for 20220101. The server reports the date as valid but returns no records.
     Ejecución interrumpida
     ```

*   R CMD check timed out


