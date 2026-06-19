#' Spanish subdivision codes and names
#'
#' @description
#' A [tibble][tibble::tbl_df] object used internally to translate codes and
#' names for different Spanish subdivisions. This tibble provides a
#' hierarchical representation of Spain's subdivisions, including NUTS 1,
#' Autonomous Communities and Cities (equivalent to NUTS 2), provinces and
#' province-level NUTS 3 units. See the note below for coverage details.
#'
#' @format
#' A [tibble][tibble::tbl_df] with `r nrow(mapSpain::esp_codelist)` rows and
#' columns:
#'
#' \describe{
#'  \item{nuts1.code}{NUTS 1 code.}
#'  \item{nuts1.name}{NUTS 1 name.}
#'  \item{nuts1.name.alt}{NUTS 1 alternative name.}
#'  \item{nuts1.shortname.es}{NUTS 1 short (common) name (Spanish).}
#'  \item{codauto}{INE code of the Autonomous Community or City.}
#'  \item{iso2.ccaa.code}{ISO2 code of the Autonomous Community or City.}
#'  \item{nuts2.code}{NUTS 2 code.}
#'  \item{ine.ccaa.name}{INE name of the Autonomous Community or City.}
#'  \item{iso2.ccaa.name.es}{ISO2 name of the Autonomous Community or City
#'     (Spanish).}
#'  \item{iso2.ccaa.name.ca}{ISO2 name of the Autonomous Community or City
#'     (Catalan).}
#'  \item{iso2.ccaa.name.gl}{ISO2 name of the Autonomous Community or City
#'     (Galician).}
#'  \item{iso2.ccaa.name.eu}{ISO2 name of the Autonomous Community or City
#'     (Basque).}
#'  \item{nuts2.name}{NUTS 2 name.}
#'  \item{cldr.ccaa.name.en}{CLDR name of the Autonomous Community or City
#'     (English).}
#'  \item{cldr.ccaa.name.es}{CLDR name of the Autonomous Community or City
#'     (Spanish).}
#'  \item{cldr.ccaa.name.ca}{CLDR name of the Autonomous Community or City
#'     (Catalan).}
#'  \item{cldr.ccaa.name.ga}{CLDR name of the Autonomous Community or City
#'     (Galician).}
#'  \item{cldr.ccaa.name.eu}{CLDR name of the Autonomous Community or City
#'     (Basque).}
#'  \item{ccaa.shortname.en}{Short (common) name of the subdivision
#'     (English).}
#'  \item{ccaa.shortname.es}{Short (common) name of the subdivision
#'     (Spanish).}
#'  \item{ccaa.shortname.ca}{Short (common) name of the subdivision
#'     (Catalan).}
#'  \item{ccaa.shortname.ga}{Short (common) name of the subdivision
#'     (Galician).}
#'  \item{ccaa.shortname.eu}{Short (common) name of the subdivision (Basque).}
#'  \item{cpro}{INE code of the province.}
#'  \item{iso2.prov.code}{ISO2 code of the province.}
#'  \item{nuts.prov.code}{NUTS code of the province.}
#'  \item{ine.prov.name}{INE name of the province.}
#'  \item{iso2.prov.name.es}{ISO2 name of the province (Spanish).}
#'  \item{iso2.prov.name.ca}{ISO2 name of the province (Catalan).}
#'  \item{iso2.prov.name.ga}{ISO2 name of the province (Galician).}
#'  \item{iso2.prov.name.eu}{ISO2 name of the province (Basque).}
#'  \item{cldr.prov.name.en}{CLDR name of the province (English).}
#'  \item{cldr.prov.name.es}{CLDR name of the province (Spanish).}
#'  \item{cldr.prov.name.ca}{CLDR name of the province (Catalan).}
#'  \item{cldr.prov.name.ga}{CLDR name of the province (Galician).}
#'  \item{cldr.prov.name.eu}{CLDR name of the province (Basque).}
#'  \item{prov.shortname.en}{Short (common) name of the province (English).}
#'  \item{prov.shortname.es}{Short (common) name of the province (Spanish).}
#'  \item{prov.shortname.ca}{Short (common) name of the province (Catalan).}
#'  \item{prov.shortname.ga}{Short (common) name of the province (Galician).}
#'  \item{prov.shortname.eu}{Short (common) name of the province (Basque).}
#'  \item{nuts3.code}{NUTS 3 code.}
#'  \item{nuts3.name}{NUTS 3 name.}
#'  \item{nuts3.shortname.es}{NUTS 3 short (common) name.}
#' }
#'
#' @source
#' - **INE**: Instituto Nacional de Estadística, <https://www.ine.es/>.
#' - **Eurostat (NUTS)**: <https://ec.europa.eu/eurostat/web/nuts/overview>.
#' - **ISO**: <https://www.iso.org/obp/ui/#iso:code:3166:ES>.
#' - **CLDR**:
#'   <https://www.unicode.org/cldr/charts/48/subdivisionNames/index.html>
#'
#' @note
#' Although NUTS 2 aligns with the first subdivision level of Spain
#' (Autonomous Communities and Cities), NUTS 3 does not correspond to the second
#' subdivision level of Spain (provinces). NUTS 3 provides dedicated codes for
#' major islands, whereas provinces do not.
#'
#' Ceuta and Melilla have special status as Autonomous Cities but are
#' represented at the Autonomous Communities and Cities level with a single
#' province, like Madrid, Asturias or Murcia, in this database.
#'
#' @family datasets
#' @docType data
#' @name esp_codelist
#'
#' @encoding UTF-8
#' @examples
#'
#' data("esp_codelist")
#' esp_codelist
NULL

#' Population of Spain by municipality (2025)
#'
#' @format
#' A [tibble][tibble::tbl_df] object with
#' `r prettyNum(nrow(mapSpain::pobmun25), big.mark=",")` rows containing
#' population data by municipality in Spain for 2025.
#'
#' \describe{
#'   \item{cpro}{INE code of the province.}
#'   \item{provincia}{Name of the province.}
#'   \item{cmun}{INE code of the municipality.}
#'   \item{name}{Name of the municipality.}
#'   \item{pob25}{Total population (2025).}
#'   \item{men}{Male population (2025).}
#'   \item{women}{Female population (2025).}
#' }
#'
#' @source
#' INE, Instituto Nacional de Estadística.
#'
#' ```{r, echo=FALSE, results='asis'}
#' cat(paste0(
#'    " <https://www.ine.es/dyngs/INEbase/categoria.htm?c=Estadistica_P",
#'      "&cid=1254734710990>.")
#'      )
#'
#' ```
#'
#' @family datasets
#' @docType data
#' @name pobmun25
#'
#' @encoding UTF-8
#' @examples
#' data("pobmun25")
NULL

#' Public WMS and WMTS providers for Spain
#'
#' @description
#' A named [`list`][base::list] of length `r length(esp_tiles_providers)`,
#' containing URL information from different public WMS and WMTS tile providers
#' in Spain.
#'
#' This dataset is an implementation of the JavaScript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **`r leaf_providers_esp_v`**.
#'
#' @details
#' Providers available to be passed to `type` in [esp_get_tiles()] are:
#'
#' ```{r, echo=FALSE, comment="", results="asis"}
#'
#' t <- names(mapSpain::esp_tiles_providers)
#' t <- paste0('\n - `"', t, '"`')
#'
#' cat(t)
#'
#' ```
#' @format
#' A named [`list`][base::list] of available providers with the following
#' structure:
#'
#' Each list item is named with the provider alias. Each element contains two
#' nested named lists: `static` with the parameters required to obtain static
#' map tiles plus an additional item named `attribution`, and `leaflet` with
#' additional parameters to pass to [addProviderEspTiles()].
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/>, a plugin for
#' \CRANpkg{leaflet},
#' **`r leaf_providers_esp_v`**.
#'
#' @family datasets
#' @docType data
#' @name esp_tiles_providers
#'
#' @encoding UTF-8
#' @examples
#' data("esp_tiles_providers")
#' # Get a single provider.
#'
#' single <- esp_tiles_providers[["IGNBase.Todo"]]
#' single$static
#'
#' single$leaflet
#'
NULL

#' NUTS 2024 for Spain [`sf`][sf::st_sf] object
#'
#' @description
#' This dataset represents Spanish subdivisions at NUTS levels 0, 1, 2 and 3
#' according to the Nomenclature of Territorial Units for Statistics (NUTS)
#' classification for 2024.
#'
#' @inherit giscoR::gisco_nuts_2024 details
#'
#' @format
#' An [`sf`][sf::st_sf] object with `MULTIPOLYGON` geometries at 1:1 million
#' resolution in [EPSG:4258](https://epsg.io/4258) projection, containing
#' `r nrow(mapSpain::esp_nuts_2024)` rows and 10 variables:
#' \describe{
#'   \item{`NUTS_ID`}{NUTS identifier.}
#'   \item{`LEVL_CODE`}{NUTS level code `(0, 1, 2, 3)`.}
#'   \item{`CNTR_CODE`}{Eurostat country code.}
#'   \item{`NAME_LATN`}{NUTS name in Latin characters.}
#'   \item{`NUTS_NAME`}{NUTS name in the local alphabet.}
#'   \item{`MOUNT_TYPE`}{Mountain type, see **Details**.}
#'   \item{`URBN_TYPE`}{Urban type, see **Details**.}
#'   \item{`COAST_TYPE`}{Coastal type, see **Details**.}
#'   \item{`geo`}{Same as `NUTS_ID`, provided for compatibility with
#'     \CRANpkg{eurostat}.}
#'   \item{`geometry`}{Geometry field.}
#' }
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
#' @seealso [esp_get_nuts()]
#' @family datasets
#' @docType data
#' @name esp_nuts_2024
#'
#' @encoding UTF-8
#' @examples
#' data("esp_nuts_2024")
#' head(esp_nuts_2024)
#'
NULL
