# Public WMS and WMTS providers for Spain

A named [`list`](https://rdrr.io/r/base/list.html) of length 174,
containing URL information from different public WMS and WMTS tile
providers in Spain.

This dataset is an implementation of the JavaScript plugin
[leaflet-providersESP](https://dieghernan.github.io/leaflet-providersESP/)
**v1.5.0**.

## Format

A named [`list`](https://rdrr.io/r/base/list.html) of available
providers with the following structure:

Each list item is named with the provider alias. Each element contains
two nested named lists. `static` contains the parameters required to
obtain static map tiles and an additional item named `attribution`.
`leaflet` contains additional parameters to pass to
[`addProviderEspTiles()`](https://ropenspain.github.io/mapSpain/dev/reference/addProviderEspTiles.md).

## Source

<https://dieghernan.github.io/leaflet-providersESP/>, a plugin for
[leaflet](https://CRAN.R-project.org/package=leaflet), **v1.5.0**.

## Details

Compare layers in the
[preview](https://dieghernan.github.io/leaflet-providersESP/preview/)
and consult the [layer
guide](https://dieghernan.github.io/leaflet-providersESP/capas/) for
coverage, scale and availability information.

Providers available to be passed to `type` in
[`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_tiles.md)
are:

- `"IDErioja"`

- `"IDErioja.Base"`

- `"IDErioja.Relieve"`

- `"IDErioja.Claro"`

- `"IDErioja.Oscuro"`

- `"IGNBase"`

- `"IGNBase.Todo"`

- `"IGNBase.Simplificado"`

- `"IGNBase.Gris"`

- `"IGNBase.TodoNoFondo"`

- `"IGNBase.Orto"`

- `"MDT"`

- `"MDT.Elevaciones"`

- `"MDT.Relieve"`

- `"MDT.CurvasNivel"`

- `"MDT.SpotElevation"`

- `"PNOA"`

- `"PNOA.MaximaActualidad"`

- `"PNOA.Mosaico"`

- `"OcupacionSuelo"`

- `"OcupacionSuelo.Ocupacion"`

- `"OcupacionSuelo.Usos"`

- `"LiDAR"`

- `"MTN"`

- `"Geofisica"`

- `"Geofisica.Terremotos10dias"`

- `"Geofisica.Terremotos30dias"`

- `"Geofisica.Terremotos365dias"`

- `"Geofisica.ObservedEvents"`

- `"Geofisica.EstacionesSismicas"`

- `"Geofisica.HazardArea2015PGA"`

- `"Geofisica.HazardArea2015Isolineas"`

- `"Geofisica.HazardArea2015Intensidad"`

- `"Geofisica.HazardArea2002"`

- `"Geofisica.HazardArea"`

- `"VigilanciaVolcanica"`

- `"VigilanciaVolcanica.ErupcionesHistoricas"`

- `"CaminoDeSantiago"`

- `"CaminoDeSantiago.CaminoFrances"`

- `"CaminoDeSantiago.CaminosFrancia"`

- `"CaminoDeSantiago.CaminosGalicia"`

- `"CaminoDeSantiago.CaminosDelNorte"`

- `"CaminoDeSantiago.CaminosAndaluces"`

- `"CaminoDeSantiago.CaminosCentro"`

- `"CaminoDeSantiago.CaminosEste"`

- `"CaminoDeSantiago.CaminosNordeste"`

- `"CaminoDeSantiago.CaminosCatalanes"`

- `"CaminoDeSantiago.CaminosSureste"`

- `"CaminoDeSantiago.CaminosInsulares"`

- `"CaminoDeSantiago.CaminosPortugueses"`

- `"Catastro"`

- `"Catastro.Catastro"`

- `"Catastro.Parcela"`

- `"Catastro.CadastralParcel"`

- `"Catastro.CadastralZoning"`

- `"Catastro.Address"`

- `"Catastro.Building"`

- `"Catastro.BuildingPart"`

- `"Catastro.AdministrativeBoundary"`

- `"Catastro.AdministrativeUnit"`

- `"RedTransporte"`

- `"RedTransporte.Carreteras"`

- `"RedTransporte.Ferroviario"`

- `"RedTransporte.Aerodromo"`

- `"RedTransporte.Pistas"`

- `"RedTransporte.CallesRodaje"`

- `"RedTransporte.Plataformas"`

- `"RedTransporte.TransporteCable"`

- `"RedTransporte.AreaServicio"`

- `"RedTransporte.EstacionesFerroviario"`

- `"RedTransporte.Puertos"`

- `"Cartociudad"`

- `"Cartociudad.CodigosPostales"`

- `"Cartociudad.Direcciones"`

- `"NombresGeograficos"`

- `"UnidadesAdm"`

- `"UnidadesAdm.Limites"`

- `"UnidadesAdm.LimitesHistoricos"`

- `"UnidadesAdm.Unidades"`

- `"Hidrografia"`

- `"Hidrografia.MasaAgua"`

- `"Hidrografia.Cuencas"`

- `"Hidrografia.Subcuencas"`

- `"Hidrografia.POI"`

- `"Hidrografia.ManMade"`

- `"Hidrografia.LineaCosta"`

- `"Hidrografia.Rios"`

- `"Hidrografia.Humedales"`

- `"Militar"`

- `"Militar.CEGET1M"`

- `"Militar.CEGETM7814"`

- `"Militar.CEGETM7815"`

- `"Militar.CEGETM682"`

- `"Militar.CECAF1M"`

- `"ADIF"`

- `"ADIF.Vias"`

- `"ADIF.Nodos"`

- `"ADIF.Estaciones"`

- `"LimitesMaritimos"`

- `"LimitesMaritimos.LimitesMaritimos"`

- `"LimitesMaritimos.LineasBase"`

- `"Copernicus"`

- `"Copernicus.Forest"`

- `"Copernicus.ForestLeaf"`

- `"Copernicus.WaterWet"`

- `"Copernicus.SoilSeal"`

- `"Copernicus.GrassLand"`

- `"Copernicus.RiparianLandCover"`

- `"Copernicus.Natura2k"`

- `"Copernicus.UrbanAtlas"`

- `"Copernicus.RiparianGreen"`

- `"PNOAHistorico"`

- `"PNOAHistorico.Americano"`

- `"PNOAHistorico.Interministerial"`

- `"PNOAHistorico.Nacional"`

- `"PNOAHistorico.OLISTAT"`

- `"PNOAHistorico.SIGPAC"`

- `"PNOAHistorico.PNOA2004"`

- `"PNOAHistorico.PNOA2009"`

- `"PNOAHistorico.PNOA2014"`

- `"PNOAHistorico.PNOA2019"`

- `"PNOAHistorico.PNOA2024"`

- `"MTNHistorico"`

- `"MTNHistorico.MTN50"`

- `"MTNHistorico.MTN25"`

- `"MTNHistorico.Minutas"`

- `"Inundaciones"`

- `"Inundaciones.FluvialT10"`

- `"Inundaciones.FluvialT100"`

- `"Inundaciones.FluvialT500"`

- `"Inundaciones.MarinaT100"`

- `"Inundaciones.MarinaT500"`

- `"RedNatura"`

- `"RedNatura.General"`

- `"EspaciosProtegidos"`

- `"EspaciosProtegidos.General"`

- `"SeccionesINE"`

- `"SeccionesINE.Secciones2026"`

- `"SeccionesINE.Distritos2026"`

- `"SeccionesINE.Secciones2021"`

- `"SeccionesINE.Distritos2021"`

- `"Pendientes"`

- `"Pendientes.MDP05"`

- `"GEODE"`

- `"GEODE.Geologia"`

- `"GEODE.Unidades"`

- `"GEODE.Contactos"`

- `"GEODE.Cuaternario"`

- `"SIGPAC"`

- `"SIGPAC.Recintos"`

- `"SIGPAC.CultivoDeclarado2025"`

- `"SIGPAC.PaisajeAreas"`

- `"SIGPAC.PaisajeLineas"`

- `"SIGPAC.PaisajePuntos"`

- `"MapaForestal"`

- `"MapaForestal.Usos"`

- `"Planimetrias"`

- `"Planimetrias.Minutas"`

- `"CaminosNaturales"`

- `"CaminosNaturales.Etapas"`

- `"SpainByBike"`

- `"SpainByBike.Etapas"`

- `"SpainByBike.TiposVia"`

- `"SpainByBike.CentrosBTT"`

- `"SpainByBike.Puertos"`

- `"SpainByBike.PuertosPuntos"`

- `"ViasPecuarias"`

- `"ViasPecuarias.Red2024"`

- `"PotencialSolar"`

- `"PotencialSolar.Global"`

- `"PotencialSolar.Edificios"`

- `"ParquesNaturales"`

- `"ParquesNaturales.Limites"`

- `"ParquesNaturales.ZonasPerifericas"`

## See also

- [`esp_get_tiles()`](https://ropenspain.github.io/mapSpain/dev/reference/esp_get_tiles.md)
  downloads static map tiles from these providers.

- [`addProviderEspTiles()`](https://ropenspain.github.io/mapSpain/dev/reference/addProviderEspTiles.md)
  adds these providers to interactive maps.

Included package datasets:
[`esp_codelist`](https://ropenspain.github.io/mapSpain/dev/reference/esp_codelist.md),
[`esp_nuts_2024`](https://ropenspain.github.io/mapSpain/dev/reference/esp_nuts_2024.md),
[`pobmun25`](https://ropenspain.github.io/mapSpain/dev/reference/pobmun25.md)

## Examples

``` r
data("esp_tiles_providers")
# Get a single provider.

single <- esp_tiles_providers[["IGNBase.Todo"]]
single$static
#> $attribution
#> [1] "CC BY 4.0 scne.es. Sistema Geográfico Nacional IGN "
#> 
#> $q
#> [1] "https://www.ign.es/wmts/ign-base?"
#> 
#> $service
#> [1] "WMTS"
#> 
#> $request
#> [1] "GetTile"
#> 
#> $version
#> [1] "1.0.0"
#> 
#> $format
#> [1] "image/png"
#> 
#> $layer
#> [1] "IGNBaseTodo"
#> 
#> $style
#> [1] "default"
#> 
#> $tilematrixset
#> [1] "GoogleMapsCompatible"
#> 
#> $tilematrix
#> [1] "{z}"
#> 
#> $tilerow
#> [1] "{y}"
#> 
#> $tilecol
#> [1] "{x}"
#> 

single$leaflet
#> $attribution
#> [1] "CC BY 4.0 scne.es. Sistema Geogr&aacute;fico Nacional <a href='http://www.ign.es'>IGN</a> "
#> 
#> $maxNativeZoom
#> [1] 20
#> 
```
