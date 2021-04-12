#' Spanish Code Translation Data Frame
#'
#' @concept datasets
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
#' * INE: Instituto Nacional de Estadistica: <https://www.ine.es/>
#' * Eurostat (NUTS): <https://ec.europa.eu/eurostat/web/nuts/background>
#' * ISO: <https://www.iso.org/obp/ui/#iso:code:3166:ES>
#' * CLDR: <https://unicode-org.github.io/cldr-staging/charts/38/index.html>
#'
#' @encoding UTF-8
#'
#' @format
#' data frame with codes as columns
#'   * \strong{nuts*.code}: NUTS code of each subdivision.
#'   * \strong{nuts*.code}: NUTS name of each subdivision.
#'   * \strong{codauto}: INE code of each autonomous community.
#'   * \strong{iso2.*.code}: ISO2 code of each autonomous
#'   community and province.
#'   * \strong{ine.*.name}: INE name of each autonomous community
#'   and province.
#'   * \strong{iso2.*.name.(lang)}: ISO2 name of each autonomous community
#'   and province. Several languages available.
#'   * \strong{cldr.*.name.(lang)}: CLDR name of each autonomous community and
#'   province. Several languages available.
#'   * \strong{ccaa.short.*}: Short (common) name of each autonomous
#'   community. Several languages available.
#'   * \strong{cpro}: INE code of each province.
#'   * \strong{prov.shortname.*}: Short (common) name of each province.
#'   Several languages available.
#'
#' @note
#' Languages available are:
#'   * "en": English
#'   * "es": Spanish
#'   * "ca": Catalan
#'   * "ga": Galician
#'   * "eu": Basque
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
#' library(tibble)
#'
#' glimpse(as_tibble(esp_codelist))
NULL


#' All NUTS `POLYGON` object of Spain
#'
#' @concept datasets
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
#' @seealso [esp_get_nuts()]
#'
#' @format
#' A `POLYGON` data frame (resolution: 1:1million, EPSG:4258) object with 86
#' rows and fields:
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

#' All Municipalities `POLYGON` object of Spain
#'
#' @concept datasets
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
#' @seealso [esp_get_munic()]
#' @format
#' A `POLYGON` data frame (resolution: 1:1million, EPSG:4258) object:
#'   * codauto: INE code of each autonomous community.
#'   * ine.ccaa.name: INE name of each autonomous community.
#'   * cpro: INE code of each province.
#'   * ine.prov.name: INE name of each province.
#'   * cmun: INE code of each municipality.
#'   * name: Name of the municipality.
#'   * LAU_CODE: LAU Code (GISCO) of the municipality.
#'   * geometry: geometry field.
#'
#' @example inst/examples/esp_munic_sf.R
NULL


#' @title Population by municipality (2019)
#'
#' @concept datasets
#'
#' @name pobmun19
#'
#' @docType data
#'
#' @description
#' A data frame with 8131 rows containing the population data by municipality
#' in Spain (2019).
#'
#' @source INE: Instituto Nacional de Estadistica <https://www.ine.es/>
NULL


#' @title Public WMS and WMTS of Spain
#'
#' @concept datasets
#'
#' @name leaflet.providersESP.df
#'
#' @description
#' A data frame containing information of different public WMS and WMTS
#' providers of Spain
#'
#' This function is a implementation of the javascript plugin
#' [leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
#' **v1.2.0**.
#'
#' @docType data
#'
#' @source
#' <https://dieghernan.github.io/leaflet-providersESP/> leaflet plugin,
#' **v1.2.0**.
#'
#' @encoding UTF-8
#'
#' @seealso [esp_getTiles()], [addProviderEspTiles()].
#'
#' @format
#' A data frame object with a list of the required parameters for calling
#' the service:
#'   * provider: Provider name.
#'   * field: Description of `value`.
#'   * value: INE code of each province.
#'
#'
#' @details
#' Providers available to be passed to `type` are:
#'   * **IDErioja:** "IDErioja"
#'   * **IGNBase:** "IGNBase.Todo", "IGNBase.Gris", "IGNBase.TodoNoFondo,
#'     IGNBase.Orto"
#'   * **MDT:** "MDT.Elevaciones", "MDT.Relieve", "MDT.CurvasNivel"
#'   * **PNOA:** "PNOA.MaximaActualidad", "PNOA.Mosaico"
#'   * **OcupacionSuelo:** "OcupacionSuelo.Ocupacion", "OcupacionSuelo.Usos"
#'   * **LiDAR:** "LiDAR"
#'   * **MTN:** "MTN"
#'   * **Geofisica:** "Geofisica.Terremotos10dias",
#'     "Geofisica.Terremotos30dias", "Geofisica.Terremotos365dias",
#'     "Geofisica.VigilanciaVolcanica"
#'   * **CaminoDeSantiago:** "CaminoDeSantiago.CaminoFrances",
#'     "CaminoDeSantiago.CaminosTuronensis", "CaminoDeSantiago.CaminosGalicia",
#'     "CaminoDeSantiago.CaminosDelNorte", "CaminoDeSantiago.CaminosAndaluces",
#'     "CaminoDeSantiago.CaminosCentro", "CaminoDeSantiago.CaminosEste",
#'     "CaminoDeSantiago.CaminosCatalanes", "CaminoDeSantiago.CaminosSureste",
#'     "CaminoDeSantiago.CaminosInsulares", "CaminoDeSantiago.CaminosPiemonts",
#'     "CaminoDeSantiago.CaminosTolosana", "CaminoDeSantiago.CaminosPortugueses"
#'   * **Catastro:** "Catastro.Catastro", "Catastro.Parcela",
#'     "Catastro.CadastralParcel", "Catastro.CadastralZoning",
#'     "Catastro.Address", "Catastro.Building"
#'   * **RedTransporte:** "RedTransporte.Carreteras",
#'     "RedTransporte.Ferroviario", "RedTransporte.Aerodromo",
#'     "RedTransporte.AreaServicio", "RedTransporte.EstacionesFerroviario",
#'     "RedTransporte.Puertos"
#'   * **Cartociudad:** "Cartociudad.CodigosPostales", "Cartociudad.Direcciones"
#'   * **NombresGeograficos:** "NombresGeograficos"
#'   * **UnidadesAdm:** "UnidadesAdm.Limites", "UnidadesAdm.Unidades"
#'   * **Hidrografia:** "Hidrografia.MasaAgua", "Hidrografia.Cuencas",
#'     "Hidrografia.Subcuencas", "Hidrografia.POI", "Hidrografia.ManMade",
#'     "Hidrografia.LineaCosta", "Hidrografia.Rios", "Hidrografia.Humedales"
#'   * **Militar:** "Militar.CEGET1M", "Militar.CEGETM7814",
#'      "Militar.CEGETM7815", "Militar.CEGETM682", "Militar.CECAF1M"
#'   * **ADIF:** "ADIF.Vias", "ADIF.Nodos", "ADIF.Estaciones"
#'   * **LimitesMaritimos:** "LimitesMaritimos.LimitesMaritimos",
#'     "LimitesMaritimos.LineasBase"
#'   * **Copernicus:** "Copernicus.LandCover", "Copernicus.Forest",
#'       "Copernicus.ForestLeaf", "Copernicus.WaterWet", "Copernicus.SoilSeal",
#'       "Copernicus.GrassLand", "Copernicus.Local", "Copernicus.RiparianGreen",
#'    "Copernicus.RiparianLandCover", "Copernicus.Natura2k",
#'    "Copernicus.UrbanAtlas"
#'   * **ParquesNaturales:** "ParquesNaturales.Limites",
#'     "ParquesNaturales.ZonasPerifericas"
#'
NULL
