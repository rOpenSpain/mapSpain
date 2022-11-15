#' Spanish Code Translation Data Frame
#'
#' @family datasets
#' @family political
#' @family dictionary
#'
#' @name esp_codelist
#'
#' @docType data
#'
#' @description
#' A data frame used internally for translating codes and names of the
#' different subdivisions of Spain. The data frame provides the hierarchy of
#' the subdivisions including NUTS1 level, Autonomous Communities
#' (equivalent to NUTS2), Provinces and NUTS3 level. See Note.
#'
#' @source
#' * **INE**: Instituto Nacional de Estadistica: <https://www.ine.es/>
#' * **Eurostat (NUTS)**: <https://ec.europa.eu/eurostat/web/nuts/background>
#' * **ISO**: <https://www.iso.org/home.html>
#' * **CLDR**: <https://unicode-org.github.io/cldr-staging/charts/38/index.html>
#'
#' @encoding UTF-8
#'
#' @format
#' A data frame with `r nrow(mapSpain::esp_codelist)` rows
#' codes as columns
#'   * **nuts+.code**: NUTS code of each subdivision.
#'   * **nuts+.code**: NUTS name of each subdivision.
#'   * **codauto**: INE code of each autonomous community.
#'   * **iso2.+.code**: ISO2 code of each autonomous
#'   community and province.
#'   * **ine.+.name**: INE name of each autonomous community
#'   and province.
#'   * **iso2.+.name.(lang)**: ISO2 name of each autonomous community
#'   and province. Several languages available.
#'   * **cldr.+.name.(lang)**: CLDR name of each autonomous community and
#'   province. Several languages available.
#'   * **ccaa.short.+**: Short (common) name of each autonomous
#'   community. Several languages available.
#'   * **cpro**: INE code of each province.
#'   * **prov.shortname.+**: Short (common) name of each province.
#'   Several languages available.
#'
#' @note
#' Languages available are:
#'   * **"en"**: English
#'   * **"es"**: Spanish
#'   * **"ca"**: Catalan
#'   * **"ga"**: Galician
#'   * **"eu"**: Basque
#'
#' Although NUTS2 matches the first subdivision level of Spain
#' (CCAA - Autonomous Communities), it should be noted that NUTS3 does not
#' match the second subdivision level of Spain (Provinces). NUTS3 provides a
#' dedicated code for major islands whereas the Provinces doesn't.
#'
#' Ceuta and Melilla has an specific status (Autonomous Cities) but are
#' considered as communities with a single province (as Madrid, Asturias
#' or Murcia) on this dataset.
#'
#' @examples
#'
#' data("esp_codelist")
NULL


#' All NUTS `POLYGON` object of Spain
#'
#' @family datasets
#' @family nuts
#'
#' @name esp_nuts.sf
#'
#' @docType data
#'
#' @description
#' A `sf` object including all NUTS levels of Spain as provided by
#' GISCO (2016 version).
#'
#' @source
#' <https://gisco-services.ec.europa.eu/distribution/v2/nuts/>, file
#' `NUTS_RG_20M_2016_4326.geojson`.
#'
#' @encoding UTF-8
#'
#'
#' @format
#' A `POLYGON` data frame (resolution: 1:1million, EPSG:4258) object with
#' `r prettyNum(nrow(mapSpain::esp_nuts.sf), big.mark=",")` rows and fields:
#'   * COAST_TYPE: COAST_TYPE
#'   * FID: FID
#'   * NUTS_NAME: NUTS name on local alphabet
#'   * MOUNT_TYPE: MOUNT_TYPE
#'   * NAME_LATN: Name on Latin characters
#'   * CNTR_CODE: Eurostat Country code
#'   * URBN_TYPE: URBN_TYPE
#'   * NUTS_ID: NUTS identifier
#'   * LEVL_CODE: NUTS level code (0,1,2,3)
#'   * geometry: geometry field
#'
#' @example inst/examples/esp_nuts_sf.R
NULL

#' All Municipalities `POLYGON` object of Spain (2019)
#'
#' @family datasets
#' @family municipalities
#'
#' @name esp_munic.sf
#'
#' @description
#' A `sf` object including all municipalities of Spain as provided by GISCO
#' (2019 version).
#'
#' @docType data
#'
#' @source
#' <https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/>, LAU 2019
#' data.
#'
#' @encoding UTF-8
#'
#' @seealso [esp_get_munic()].
#' @format
#' A `POLYGON` data frame (resolution: 1:1million, EPSG:4258) object with
#' `r prettyNum(nrow(mapSpain::esp_munic.sf), big.mark=",")` rows and fields:
#'   * **codauto**: INE code of each autonomous community.
#'   * **ine.ccaa.name**: INE name of each autonomous community.
#'   * **cpro**: INE code of each province.
#'   * **ine.prov.name**: INE name of each province.
#'   * **cmun**: INE code of each municipality.
#'   * **name**: Name of the municipality.
#'   * **LAU_CODE**: LAU Code (GISCO) of the municipality. This is a
#'     combination of **cpro** and **cmun**, aligned with INE coding scheme.
#'   * **geometry**: geometry field.
#'
#' @example inst/examples/esp_munic_sf.R
NULL


#' @title Population by municipality (2019)
#'
#' @family datasets
#'
#' @name pobmun19
#'
#' @docType data
#'
#' @description
#' A data frame with `r prettyNum(nrow(mapSpain::pobmun19), big.mark=",")`
#' rows containing the population data by municipality in Spain (2019).
#'
#' @source INE: Instituto Nacional de Estadistica <https://www.ine.es/>
#'
#' @examples
#' data("pobmun19")
NULL


#' @title Public WMS and WMTS of Spain
#'
#' @family datasets
#' @family imagery utilities
#'
#' @name leaflet.providersESP.df
#'
#' @description
#' A data frame containing information of different public WMS and WMTS
#' providers of Spain
#'
#' This function is a implementation of the javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **v1.3.2**.
#'
#' @docType data
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#' **v1.3.2**.
#'
#' @encoding UTF-8
#'
#' @format
#' A data frame object with a list of the required parameters for calling
#' the service:
#'   * **provider**: Provider name.
#'   * **field**: Description of `value`.
#'   * **value**: INE code of each province.
#'
#'
#' @details
#' Providers available to be passed to `type` on [esp_getTiles()] are:
#'
#' ```{r, echo=FALSE}
#'
#' t <- mapSpain::leaflet.providersESP.df
#' t <- paste0("'", unique(t$provider), "'")
#' t <- data.frame(provider=t)
#'
#' knitr::kable(t)
#'
#'
#' ```
#' @examples
#' data("leaflet.providersESP.df")
NULL
