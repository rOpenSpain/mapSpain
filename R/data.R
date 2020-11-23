#' @title Spanish Code Translation Data Frame
#' @name esp_codelist
#' @docType data
#' @description A data frame used internally for translating codes and
#' names of the different subdivisions of Spain. The data frame provides
#' the hierarchy of the subdivisions including NUTS1 level,
#' Autonomous Communities (equivalent to NUTS2), Provinces and NUTS3
#' level. See Note.
#' @source
#' \itemize{
#'  \item{INE: Instituto Nacional de Estadistica: }{\url{https://www.ine.es/}}
#'  \item{Eurostat (NUTS): }
#'  {\url{https://ec.europa.eu/eurostat/web/nuts/background}}
#'  \item{ISO: }{\url{https://www.iso.org/obp/ui/#iso:code:3166:ES}}
#'  \item{CLDR: }
#'  {\url{https://unicode-org.github.io/cldr-staging/charts/38/index.html}}
#' }
#' @encoding UTF-8
#' @format data frame with codes as columns
#' \itemize{
#'   \item{\strong{nuts*.code}: }{NUTS code of each subdivision.}
#'   \item{\strong{nuts*.code}: }{NUTS name of each subdivision.}
#'   \item{\strong{codauto}: }{INE code of each autonomous community.}
#'   \item{\strong{iso2.*.code}: }{ISO2 code of each autonomous
#'   community and province.}
#'   \item{\strong{ine.*.name}: }{INE name of each autonomous community
#'   and province.}
#'   \item{\strong{iso2.*.name.*}: }{ISO2 name of each autonomous community
#'   and province. Several languages available.}
#'   \item{\strong{cldr.*.name.*}: }{CLDR name of each autonomous community and
#'   province. Several languages available.}
#'   \item{\strong{ccaa.short.*}: }{Short (common) name of each autonomous
#'   community. Several languages available.}
#'   \item{\strong{cpro}: }{INE code of each province.}
#'   \item{\strong{prov.shortname.*}: }{Short (common) name of each province.
#'   Several languages available.}
#' }
#' @note Languages available are:
#' \itemize{
#'   \item{\code{en}: }{English}
#'   \item{\code{es}: }{Spanish}
#'   \item{\code{ca}: }{Catalan}
#'   \item{\code{ga}: }{Galician}
#'   \item{\code{eu}: }{Basque}
#' }
#'
#' Although NUTS2 matches the first subdivision level of Spain
#' (CCAA - Autonomous Communities), it should be noted that NUTS3 does not
#' match the second subdivision level of Spain (Provinces). NUTS3 provides a
#' dedicated code for major islands whereas the Provinces doesn't.
#'
#' Ceuta and Melilla has an specific status (Autonomous Cities) but are
#' considered as communities with a single provice (as Madrid, Asturias
#' or Murcia) on this dataset.
#' @examples
#' data(esp_codelist)
NULL


#' @title All NUTS \code{POLYGON} object of Spain
#' @name esp_nuts.sf
#' @docType data
#' @description A \code{sf} object including all
#' NUTS levels of Spain as provided by GISCO (2016 version).
#' @source
#' \href{https://gisco-services.ec.europa.eu/distribution/v2/nuts/geojson/NUTS_RG_20M_2016_4326.geojson}{GISCO .geojson source}
#' @encoding UTF-8
#' @seealso \link{esp_get_nuts}
#' @format A \code{POLYGON} data frame (resolution: 1:1million, EPSG:4258)
#' object with 86 rows and fields:
#' \describe{
#'   \item{COAST_TYPE}{COAST_TYPE}
#'   \item{FID}{FID}
#'   \item{NUTS_NAME}{NUTS name on local alphabet}
#'   \item{MOUNT_TYPE}{MOUNT_TYPE}
#'   \item{NAME_LATN}{Name on Latin characters}
#'   \item{CNTR_CODE}{Eurostat Country code}
#'   \item{URBN_TYPE}{URBN_TYPE}
#'   \item{NUTS_ID}{NUTS identifier}
#'   \item{LEVL_CODE}{NUTS level code (0,1,2,3)}
#'   \item{geometry}{geometry field}
#' }
#' @examples
#' library(sf)
#'
#' nuts <- esp_nuts.sf
#' nuts3 <- subset(nuts, LEVL_CODE == 3)
#'
#' unique(nuts3$MOUNT_TYPE)
#'
#' plot(
#'   nuts3[, "URBN_TYPE"],
#'   pal = hcl.colors(3, palette = "Viridis"),
#'   main = "Urban type -  NUTS3 levels of Spain",
#'   key.pos = NULL
#' )
NULL

#' @title All Municipalities \code{POLYGON} object of Spain
#' @name esp_munic.sf
#' @description A \code{sf} object including all
#' municipalities of Spain as provided by GISCO (2019 version).
#' @docType data
#' @source
#' \href{https://gisco-services.ec.europa.eu/distribution/v2/lau/geojson/LAU_RG_01M_2019_4326.geojson}{GISCO .geojson source}
#' @encoding UTF-8
#' @seealso \link{esp_get_munic}
#' @format A \code{POLYGON} data frame (resolution: 1:1million, EPSG:4258)
#' object:
#' \describe{
#'   \item{codauto}{INE code of each autonomous community.}
#'   \item{ine.ccaa.name}{INE name of each autonomous community.}
#'   \item{cpro}{INE code of each province.}
#'   \item{ine.prov.name}{INE name of each province.}
#'   \item{cmun}{INE code of each municipalty.}
#'   \item{name}{Name of the municipality}
#'   \item{LAU_CODE}{LAU Code (GISCO) of the municipality}
#'   \item{geometry}{geometry field}
#' }
#' @examples
#' library(sf)
#'
#' data("esp_munic.sf")
#' data("esp_nuts.sf")
#'
#' Teruel.cpro <- esp_dict_region_code("Teruel", destination = "cpro")
#' Teruel.NUTS <- esp_dict_region_code(Teruel.cpro,
#'    origin = "cpro",
#'    destination = "nuts")
#'
#' Teruel.sf <- esp_munic.sf[esp_munic.sf$cpro == Teruel.cpro, ]
#' Teruel.city <- Teruel.sf[Teruel.sf$name == "Teruel", ]
#'
#' NUTS <-
#'   esp_nuts.sf[esp_nuts.sf$LEVL_CODE == 3 &
#'              esp_nuts.sf$NUTS_ID != Teruel.NUTS,]
#'
#'
#' plot(st_geometry(Teruel.sf), col = "cornsilk")
#' plot(st_geometry(Teruel.city), col = "firebrick3", add = TRUE)
#' plot(st_geometry(NUTS), col = "wheat", add = TRUE)
#' title(main = "Municipalities of Teruel",  line = 1)
NULL


#' @title Population by municipality (2019)
#' @name pobmun19
#' @docType data
#' @description A data frame with 8131 rows containing the population
#' data by municipality in Spain (2019).
#' @source \href{https://www.ine.es/}{INE: Instituto Nacional de Estadistica}
NULL


#' @title Public WMS and WMTS of Spain
#' @name leaflet.providersESP.df
#' @description A data frame containing information of different public
#' WMS and WMTS providers of Spain
#'
#' This function is a implementation of the javascript plugin
#' \href{https://dieghernan.github.io/leaflet-providersESP/}{leaflet-providersESP}
#' \strong{v1.2.0}
#' @docType data
#' @source \href{https://dieghernan.github.io/leaflet-providersESP/}{leaflet-providersESP}
#' leaflet plugin, \strong{v1.2.0}.
#' @encoding UTF-8
#' @seealso \link{esp_getTiles}
#'
#' @format A data frame object with a list of the required parameters
#' for calling the service:
#' \describe{
#'   \item{provider}{Provider name}
#'   \item{field}{Description of \code{value}}
#'   \item{value}{INE code of each province.}
#' }
#'
#' @details Providers available to be passed to \code{type} are:
#' \itemize{
#'  \item{\bold{IDErioja}: }{\code{IDErioja}}
#'  \item{\bold{IGNBase}: }{\code{IGNBase.Todo}, \code{IGNBase.Gris},
#'  \code{IGNBase.TodoNoFondo}, \code{IGNBase.Orto}}
#'  \item{\bold{MDT}: }{\code{MDT.Elevaciones}, \code{MDT.Relieve},
#'  \code{MDT.CurvasNivel}}
#'  \item{\bold{PNOA}: }{\code{PNOA.MaximaActualidad}, \code{PNOA.Mosaico}}
#'  \item{\bold{OcupacionSuelo}: }{\code{OcupacionSuelo.Ocupacion},
#'  \code{OcupacionSuelo.Usos}}
#'  \item{\bold{LiDAR}: }{\code{LiDAR}}
#'  \item{\bold{MTN}: }{\code{MTN}}
#'  \item{\bold{Geofisica}: }{\code{Geofisica.Terremotos10dias},
#'  \code{Geofisica.Terremotos30dias}, \code{Geofisica.Terremotos365dias},
#'  \code{Geofisica.VigilanciaVolcanica}}
#'  \item{\bold{CaminoDeSantiago}: }{\code{CaminoDeSantiago.CaminoFrances},
#'  \code{CaminoDeSantiago.CaminosTuronensis},
#'  \code{CaminoDeSantiago.CaminosGalicia},
#'  \code{CaminoDeSantiago.CaminosDelNorte},
#'  \code{CaminoDeSantiago.CaminosAndaluces},
#'  \code{CaminoDeSantiago.CaminosCentro},
#'  \code{CaminoDeSantiago.CaminosEste},
#'  \code{CaminoDeSantiago.CaminosCatalanes},
#'  \code{CaminoDeSantiago.CaminosSureste},
#'  \code{CaminoDeSantiago.CaminosInsulares},
#'  \code{CaminoDeSantiago.CaminosPiemonts},
#'  \code{CaminoDeSantiago.CaminosTolosana},
#'  \code{CaminoDeSantiago.CaminosPortugueses}}
#'  \item{\bold{Catastro}: }{\code{Catastro.Catastro},
#'  \code{Catastro.Parcela}, \code{Catastro.CadastralParcel},
#'  \code{Catastro.CadastralZoning}, \code{Catastro.Address},
#'  \code{Catastro.Building}}
#'  \item{\bold{RedTransporte}: }{\code{RedTransporte.Carreteras},
#'  \code{RedTransporte.Ferroviario}, \code{RedTransporte.Aerodromo},
#'  \code{RedTransporte.AreaServicio},
#'  \code{RedTransporte.EstacionesFerroviario},
#'  \code{RedTransporte.Puertos}}
#'  \item{\bold{Cartociudad}: }{\code{Cartociudad.CodigosPostales},
#'  \code{Cartociudad.Direcciones}}
#'  \item{\bold{NombresGeograficos}: }{\code{NombresGeograficos}}
#'  \item{\bold{UnidadesAdm}: }{\code{UnidadesAdm.Limites},
#'  \code{UnidadesAdm.Unidades}}
#'  \item{\bold{Hidrografia}: }{\code{Hidrografia.MasaAgua},
#'  \code{Hidrografia.Cuencas}, \code{Hidrografia.Subcuencas},
#'  \code{Hidrografia.POI}, \code{Hidrografia.ManMade},
#'  \code{Hidrografia.LineaCosta}, \code{Hidrografia.Rios},
#'  \code{Hidrografia.Humedales}}
#'  \item{\bold{Militar}: }{\code{Militar.CEGET1M},
#'  \code{Militar.CEGETM7814}, \code{Militar.CEGETM7815},
#'  \code{Militar.CEGETM682}, \code{Militar.CECAF1M}}
#'  \item{\bold{ADIF}: }{\code{ADIF.Vias}, \code{ADIF.Nodos},
#'  \code{ADIF.Estaciones}}
#'  \item{\bold{LimitesMaritimos}: }{\code{LimitesMaritimos.LimitesMaritimos},
#'  \code{LimitesMaritimos.LineasBase}}
#'  \item{\bold{Copernicus}: }{\code{Copernicus.LandCover},
#'  \code{Copernicus.Forest}, \code{Copernicus.ForestLeaf},
#'  \code{Copernicus.WaterWet}, \code{Copernicus.SoilSeal},
#'  \code{Copernicus.GrassLand}, \code{Copernicus.Local},
#'  \code{Copernicus.RiparianGreen}, \code{Copernicus.RiparianLandCover},
#'  \code{Copernicus.Natura2k}, \code{Copernicus.UrbanAtlas}}
#'  \item{\bold{ParquesNaturales}: }{\code{ParquesNaturales.Limites},
#'  \code{ParquesNaturales.ZonasPerifericas}}
#' }
#'
NULL
