#' mapSpain package
#'
#' @name mapSpain-package
#'
#' @aliases mapSpain
#'
#' @docType package
#'
#' @details
#'
#' |              |          |
#' | :---         | :--      |
#' | **Package**  | mapSpain |
#' | **Type**     | Package  |
#' | **Version**  | See sessionInfo() or DESCRIPTION file |
#' | **Date**     | 2021     |
#' | **License**  | GPL-3    |
#' | **LazyLoad** | yes      |
#

#' @description \if{html}{\figure{logo.png}{options: width=120 alt="mapSpain logo" align='right'}}
#' This package provides Administrative Boundaries of Spain based on
#' the GISCO (Geographic Information System of the Commission) Eurostat
#' database and CartoBase SIANE from
#' Instituto Geográfico Nacional.
#'
#' @author dieghernan, <https://github.com/dieghernan/>
#'
#' @source
#' [GISCO webpage](https://ec.europa.eu/eurostat/web/gisco/geodata)
#'
#' @references See `citation("mapSpain")`.
#'
#' @seealso
#' Useful links:
#'  * <https://ropenspain.github.io/mapSpain/>
#'  * <https://github.com/rOpenSpain/mapSpain>
#'  * Report bugs at <https://github.com/rOpenSpain/mapSpain/issues>
#'
#' @keywords package
#'
#' @note COPYRIGHT NOTICE
#'
#' When data downloaded from GISCO
#' is used in any printed or electronic publication,
#' in addition to any other provisions
#' applicable to the whole Eurostat website,
#' data source will have to be acknowledged
#' in the legend of the map and
#' in the introductory page of the publication
#' with the following copyright notice:
#'   * EN: (C) EuroGeographics for the administrative boundaries
#'   * FR: (C) EuroGeographics pour les limites administratives
#'   * DE: (C) EuroGeographics bezüglich der Verwaltungsgrenzen
#'
#' For publications in languages other than
#' English, French or German,
#' the translation of the copyright notice
#' in the language of the publication shall be used.
#'
#' If you intend to use the data commercially,
#' please contact EuroGeographics for
#' information regarding their license agreements.
NULL

# import stuffs
#' @importFrom utils download.file
#' @importFrom sf st_transform
NULL
