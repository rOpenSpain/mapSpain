#' Database with codes and names of Spanish regions
#'
#' @description
#' A [tibble][tibble::tbl_df] object used internally for translating codes and
#' names of the different subdivisions of Spain. The tibble provides the
#' hierarchy of the subdivisions including NUTS1 level, autonomous communities
#' (equivalent to NUTS2), provinces and NUTS3 level. See **Note**.
#'
#' @docType data
#' @encoding UTF-8
#' @family datasets
#' @name esp_codelist
#'
#' @source
#' - **INE**: Instituto Nacional de Estadistica: <https://www.ine.es/>
#' - **Eurostat (NUTS)**: <https://ec.europa.eu/eurostat/web/nuts/overview>
#' - **ISO**: <https://www.iso.org/obp/ui/#iso:code:3166:ES>
#' - **CLDR**:
#'   <https://www.unicode.org/cldr/charts/48/subdivisionNames/index.html>
#'
#'
#' @format
#' A [tibble][tibble::tbl_df] with `r nrow(mapSpain::esp_codelist)` rows and
#' columns:
#'
#' \describe{
#'  \item{nuts1.code}{NUTS 1 code}
#'  \item{nuts1.name}{NUTS 1 name}
#'  \item{nuts1.name.alt}{NUTS 1 alternative name}
#'  \item{nuts1.shortname.es}{NUTS1 1 short (common) name (Spanish)}
#'  \item{codauto}{INE code of the autonomous community}
#'  \item{iso2.ccaa.code}{ISO2 code of the autonomous community}
#'  \item{nuts2.code}{NUTS 2 Code}
#'  \item{ine.ccaa.name}{INE name of the autonomous community}
#'  \item{iso2.ccaa.name.es}{ISO2 name of the autonomous community (Spanish)}
#'  \item{iso2.ccaa.name.ca}{ISO2 name of the autonomous community (Catalan)}
#'  \item{iso2.ccaa.name.gl}{ISO2 name of the autonomous community (Galician)}
#'  \item{iso2.ccaa.name.eu}{ISO2 name of the autonomous community (Basque)}
#'  \item{nuts2.name}{NUTS 2 name}
#'  \item{cldr.ccaa.name.en}{CLDR name of the autonomous community (English)}
#'  \item{cldr.ccaa.name.es}{CLDR name of the autonomous community (Spanish)}
#'  \item{cldr.ccaa.name.ca}{CLDR name of the autonomous community (Catalan)}
#'  \item{cldr.ccaa.name.ga}{CLDR name of the autonomous community (Galician)}
#'  \item{cldr.ccaa.name.eu}{CLDR name of the autonomous community (Basque)}
#'  \item{ccaa.shortname.en}{Short (common) name of the autonomous community
#'     (English)}
#'  \item{ccaa.shortname.es}{Short (common) name of the autonomous community
#'     (Spanish)}
#'  \item{ccaa.shortname.ca}{Short (common) name of the autonomous community
#'     (Catalan)}
#'  \item{ccaa.shortname.ga}{Short (common) name of the autonomous community
#'     (Galician)}
#'  \item{ccaa.shortname.eu}{Short (common) name of the autonomous community
#'     (Basque)}
#'  \item{cpro}{INE code of the province}
#'  \item{iso2.prov.code}{ISO2 code of the province}
#'  \item{nuts.prov.code}{NUTS code of the province}
#'  \item{ine.prov.name}{INE name of the province}
#'  \item{iso2.prov.name.es}{ISO2 name of the province (Spanish)}
#'  \item{iso2.prov.name.ca}{ISO2 name of the province (Catalan)}
#'  \item{iso2.prov.name.ga}{ISO2 name of the province (Galician)}
#'  \item{iso2.prov.name.eu}{ISO2 name of the province (Basque)}
#'  \item{cldr.prov.name.en}{CLDR name of the province (English)}
#'  \item{cldr.prov.name.es}{CLDR name of the province (Spanish)}
#'  \item{cldr.prov.name.ca}{CLDR name of the province (Catalan)}
#'  \item{cldr.prov.name.ga}{CLDR name of the province (Galician)}
#'  \item{cldr.prov.name.eu}{CLDR name of the province (Basque)}
#'  \item{prov.shortname.en}{Short (common) name of the province (English)}
#'  \item{prov.shortname.es}{Short (common) name of the province (Spanish)}
#'  \item{prov.shortname.ca}{Short (common) name of the province (Catalan)}
#'  \item{prov.shortname.ga}{Short (common) name of the province (Galician)}
#'  \item{prov.shortname.eu}{Short (common) name of the province (Basque)}
#'  \item{nuts3.code}{NUTS 3 code}
#'  \item{nuts3.name}{NUTS 3 name}
#'  \item{nuts3.shortname.es}{NUTS 3 short (common) name}
#' }
#'
#' @note
#' Although NUTS2 matches the first subdivision level of Spain
#' (CCAA - Autonomous Communities), it should be noted that NUTS3 does not
#' match the second subdivision level of Spain (Provinces). NUTS3 provides a
#' dedicated code for major islands whereas the provinces doesn't.
#'
#' Ceuta and Melilla has an specific status (Autonomous Cities) but are
#' considered as autonomous communities with a single province (as Madrid,
#' Asturias or Murcia) on this database.
#'
#' @examples
#'
#' data("esp_codelist")
#' esp_codelist
NULL


#' Database with the population of Spain by municipality (2025)
#'
#' @docType data
#' @encoding UTF-8
#' @family datasets
#' @name pobmun25
#'
#' @format
#' An example [tibble][tibble::tbl_df] object with
#' `r prettyNum(nrow(mapSpain::pobmun25), big.mark=",")` rows containing the
#' population data by municipality in Spain (2025).
#'
#' \describe{
#'   \item{cpro}{INE code of the province.}
#'   \item{provincia}{name of the province.}
#'   \item{cmun}{INE code of the municipality.}
#'   \item{name}{Name of the municipality.}
#'   \item{pob25}{Overall population (2025)}
#'   \item{men}{Men population (2025)}
#'   \item{women}{Women population (2025)}
#' }
#'
#' @source
#' INE: Instituto Nacional de Estadistica
#'
#' ```{r, echo=FALSE, results='asis'}
#' cat(paste0(
#'    " <https://www.ine.es/dyngs/INEbase/categoria.htm?c=Estadistica_P",
#'      "&cid=1254734710990>.")
#'      )
#'
#' ```
#'
#' @examples
#' data("pobmun25")
NULL

#' Database of public WMS and WMTS of Spain
#'
#' @family datasets
#' @family images
#'
#' @name esp_tiles_providers
#'
#' @description
#' A named [`list`][base::list] of length `r length(esp_tiles_providers)`
#' containing the argument of the url information of different public WMS and
#' WMTS providers of Spain.
#'
#' Implementation of javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **`r leaf_providers_esp_v`**.
#'
#' @docType data
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#' **`r leaf_providers_esp_v`**.
#'
#' @encoding UTF-8
#'
#' @format
#' A named `list` of the providers available with the following structure:
#' - Each item of the list is named with the provider alias.
#' - Each element of the list contains two nested named lists:
#'   - `static` with the arguments to get static tiles plus an additional item
#'     named `attribution`.
#'   - `leaflet` with additional arguments to be passed onto
#'     [addProviderEspTiles()].
#'
#' @details
#' Providers available to be passed to `type` on [esp_get_tiles()] are:
#'
#' ```{r, echo=FALSE, comment="", results="asis"}
#'
#' t <- names(mapSpain::esp_tiles_providers)
#' t <- paste0('\n - `"', t, '"`')
#'
#'
#' cat(t)
#'
#'
#' ```
#' @examples
#' data("esp_tiles_providers")
#' # Get a single provider
#'
#' single <- esp_tiles_providers[["IGNBase.Todo"]]
#' single$static
#'
#' single$leaflet
#'
NULL


#' NUTS 2024 for Spain [`sf`][sf::st_sf] object
#'
#'
#' @docType data
#' @name esp_nuts_2024
#' @family datasets
#' @encoding UTF-8
#'
#' @seealso [esp_get_nuts()]
#'
#' @description
#' This dataset represents the spanish regions for levels 0, 1, 2 and 3 of the
#' Nomenclature of Territorial Units for Statistics (NUTS) for 2024.
#'
#'
#' @format
#' A [`sf`][sf::st_sf] object with `MULTIPOLYGON` geometries, resolution:
#' 1:1 million and [EPSG:4258](https://epsg.io/4258). with
#' `r nrow(mapSpain::esp_nuts_2024)` rows and 10 variables:
#' \describe{
#'   \item{`NUTS_ID`}{NUTS identifier.}
#'   \item{`LEVL_CODE`}{NUTS level code `(0,1,2,3)`.}
#'   \item{`CNTR_CODE`}{Eurostat Country code.}
#'   \item{`NAME_LATN`}{NUTS name on Latin characters.}
#'   \item{`NUTS_NAME`}{NUTS name on local alphabet.}
#'   \item{`MOUNT_TYPE`}{Mount Type, see **Details**.}
#'   \item{`URBN_TYPE`}{Urban Type, see **Details**.}
#'   \item{`COAST_TYPE`}{Coast Type, see **Details**.}
#'   \item{`geo`}{Same as `NUTS_ID`, provided for compatibility with
#'     \CRANpkg{eurostat}.}
#'   \item{`geometry`}{geometry field.}
#' }
#'
#' @details
#'
#' `MOUNT_TYPE`: Mountain typology:
#'  - `1`: More than 50 % of the surface is covered by topographic mountain
#'    areas.
#'  - `2`: More than 50 % of the regional population lives in topographic
#'    mountain areas.
#'  - `3`: More than 50 % of the surface is covered by topographic mountain
#'    areas and where more than 50 % of the regional population lives in these
#'    mountain areas.
#'  - `4`: Non-mountain region / other regions.
#'  - `0`: No classification provided.
#'
#' `URBN_TYPE`: Urban-rural typology:
#'  - `1`: Predominantly urban region.
#'  - `2`: Intermediate region.
#'  - `3`: Predominantly rural region.
#'  - `0`: No classification provided.
#'
#' `COAST_TYPE`: Coastal typology:
#'   - `1`: Coastal (on coast).
#'   - `2`: Coastal (less than 50% of population living within 50 km. of the
#'        coastline).
#'   - `3`: Non-coastal region.
#'   - `0`: No classification provided.
#'
#'
#' @source
#'
#' ```{r, echo=FALSE, results='asis'}
#'
#' cat(paste0("[NUTS_RG_01M_2024_4326.gpkg]",
#'       "(https://gisco-services.ec.europa.eu/distribution/v2/",
#'       "nuts/gpkg/) file."))
#'
#' ```
#'
#' @examples
#' data("esp_nuts_2024")
#' head(esp_nuts_2024)
#'
NULL
