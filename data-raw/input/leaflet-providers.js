// leaflet-providersESP.js plugin v1.5.0
// (c) D. Hernangomez - MIT License
// https://dieghernan.github.io/leaflet-providersESP/
// Issues: https://github.com/dieghernan/leaflet-providersESP/issues
// All providers are open source. Please check attributions
// Feel free to contribute
/* exported providersESPversion */
'use strict';
var providersESPversion = 'v1.5.0';
// Databases
// WMTS Servers - Tile Maps - Mapas de Teselas
var completeWMTS = '&style=default&tilematrixset=GoogleMapsCompatible&TileMatrix={z}&TileRow={y}&TileCol={x}';
var providersESP = {
	IDErioja: {
		url: 'https://rts.larioja.org/mapa-base/{variant}/{z}/{x}/{y}.{ext}',
		options: {
			attribution: 'CC BY 4.0 <a href=\'https://www.iderioja.org\'>www.iderioja.org</a>',
			variant: 'rioja',
			ext: 'png'
		},
		variants: {
			Base: {},
			Relieve: {
				options: {
					variant: 'rioja_relieve'
				}
			},
			Claro: {
				options: {
					variant: 'rioja_claro'
				}
			},
			Oscuro: {
				options: {
					variant: 'rioja_oscuro'
				}
			}
		}
	},
	// IGN Mapa Base
	IGNBase: {
		url: 'https://www.ign.es/wmts/ign-base?service=WMTS&request=GetTile&version=1.0.0&Format=image/{ext}&layer={variant}' + completeWMTS,
		options: {
			attribution: 'CC BY 4.0 scne.es. Sistema Geogr&aacute;fico Nacional <a href=\'http://www.ign.es\'>IGN</a> ',
			maxNativeZoom: 20,
			variant: 'IGNBaseTodo',
			ext: 'png'
		},
		variants: {
			Todo: 'IGNBaseTodo',
			Simplificado: 'IGNBaseSimplificado',
			Gris: {
				options: {
					variant: 'IGNBase-gris',
					ext: 'jpeg'
				}
			},
			TodoNoFondo: {
				options: {
					variant: 'IGNBaseTodo-nofondo',
					bounds: [
						[27, -19],
						[44, 5]
					],
					minZoom: 4
				}
			},
			Orto: {
				options: {
					variant: 'IGNBaseOrto',
					bounds: [
						[27, -19],
						[44, 5]
					],
					minZoom: 5
				}
			}
		}
	},
	// MDT
	MDT: {
		url: 'https://servicios.idee.es/wmts/mdt?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}' + completeWMTS.replace('style=default', 'style={styles}'),
		options: {
			attribution: '<a href=\'http://www.ign.es/\'>Infraestructura de Datos Espaciales de Espa&ntilde;a (IDEE)</a>',
			maxNativeZoom: 20,
			variant: 'EL.ElevationGridCoverage',
			styles: 'Elevaciones',
			bounds: [
				[22.173559281306314, -47.0716243806546],
				[
					66.88067635831743,
					40.8749629405498
				]
			]
		},
		variants: {
			Elevaciones: {},
			Relieve: {
				options: {
					variant: 'Relieve',
					styles: 'Default'
				}
			},
			CurvasNivel: {
				url: 'https://servicios.idee.es/wms-inspire/mdt?',
				options: {
					layers: 'EL.ContourLine',
					maxNativeZoom: undefined,
					styles: '',
					version: '1.3.0',
					transparent: true,
					format: 'image/png',
					minZoom: 12
				}
			},
			SpotElevation: {
				url: 'https://servicios.idee.es/wms-inspire/mdt?',
				options: {
					layers: 'EL.SpotElevation',
					maxNativeZoom: undefined,
					styles: '',
					version: '1.3.0',
					transparent: true,
					format: 'image/png',
					minZoom: 14
				}
			}
		}
	},
	// Plan Nacional de Ortofotografia Aerea
	PNOA: {
		url: 'https://www.ign.es/wmts/pnoa-ma?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer=OI.OrthoimageCoverage' + completeWMTS,
		options: {
			attribution: '{attribution.MDT}',
			maxNativeZoom: 20,
			minZoom: 4,
			bounds: [
				[22.173559281306314, -47.0716243806546],
				[
					66.88067635831743,
					40.8749629405498
				]
			]
		},
		variants: {
			MaximaActualidad: {},
			Mosaico: {
				url: 'https://www.ign.es/wms-inspire/pnoa-ma?',
				options: {
					layers: 'OI.MosaicElement',
					maxNativeZoom: undefined,
					version: '1.3.0',
					format: 'image/png',
					transparent: true
				}
			}
		}
	},
	// Ocupacion Suelo
	OcupacionSuelo: {
		url: 'https://servicios.idee.es/wmts/ocupacion-suelo?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}' + completeWMTS.replace('style=default', 'style={variant}.Default'),
		options: {
			attribution: 'CC BY 4.0 scne.es. <a href=\'http://www.ign.es/\'>Infraestructura de Datos Espaciales de Espa&ntilde;a (IDEE)</a>',
			maxNativeZoom: 20,
			variant: 'LC.LandCoverSurfaces'
		},
		variants: {
			Ocupacion: {},
			Usos: 'LU.ExistingLandUse'
		}
	},
	// Light Detection and Ranging - LiDAR
	LiDAR: {
		url: 'https://wmts-mapa-lidar.idee.es/lidar?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}' + completeWMTS,
		options: {
			attribution: '{attribution.MDT}',
			maxNativeZoom: 20,
			variant: 'EL.GridCoverageDSM'
		}
	},
	// Mapa Topografico Nacional
	MTN: {
		url: 'https://ign.es/wmts/mapa-raster?service=WMTS&request=GetTile&version=1.0.0&Format=image/jpeg&layer=MTN' + completeWMTS,
		options: {
			attribution: '{attribution.MDT}',
			maxNativeZoom: 20,
			minZoom: 4,
			bounds: [
				[22.173559281306314, -47.0716243806546],
				[
					66.88067635831743,
					40.8749629405498
				]
			]
		}
	},
	// WMS Servers
	Geofisica: {
		url: 'https://www.ign.es/wms-inspire/geofisica?',
		options: {
			layers: 'Ultimos10dias',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: '{attribution.IGNBase}'
		},
		// Selected
		variants: {
			Terremotos10dias: {},
			Terremotos30dias: 'Ultimos30dias',
			Terremotos365dias: 'Ultimos365dias',
			ObservedEvents: 'NZ.ObservedEvent',
			EstacionesSismicas: 'GE.Geophysics.seismologicalStation',
			HazardArea2015PGA: 'HazardArea2015.PGA475_p',
			HazardArea2015Isolineas: 'HazardArea2015.PGA475_c',
			HazardArea2015Intensidad: 'HazardArea2015.Int475',
			HazardArea2002: 'HazardArea2002.NCSE-02',
			HazardArea: 'HazardArea2002.NCSE-02'
		}
	},
	VigilanciaVolcanica: {
		url: 'https://wms-volcanologia.ign.es/volcanologia?',
		options: {
			layers: 'erupciones',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: '{attribution.IGNBase}'
		},
		// Selected
		variants: {
			ErupcionesHistoricas: {}
		}
	},
	CaminoDeSantiago: {
		url: 'https://www.ign.es/wms-inspire/camino-santiago?',
		options: {
			layers: 'camino_frances',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: 'CC BY 4.0 <a href=\'https://www.ign.es\'>ign.es</a>. Federaci&oacute;n Espa&ntilde;ola de Asociaciones de Amigos del Camino de Santiago (FEAACS)'
		},
		variants: {
			CaminoFrances: {},
			CaminosFrancia: 'caminos_francia',
			CaminosGalicia: 'caminos_galicia',
			CaminosDelNorte: 'caminos_norte',
			CaminosAndaluces: 'caminos_andaluces',
			CaminosCentro: 'caminos_centro',
			CaminosEste: 'caminos_este',
			CaminosNordeste: 'caminos_nordeste',
			CaminosCatalanes: 'caminos_nordeste',
			CaminosSureste: 'caminos_sureste',
			CaminosInsulares: 'caminos_insulares',
			CaminosPortugueses: 'caminos_portugueses'
		}
	},
	Catastro: {
		url: 'https://ovc.catastro.meh.es/cartografia/INSPIRE/spadgcwms.aspx',
		options: {
			layers: 'CP.CadastralParcel',
			version: '1.3.0',
			transparent: true,
			minZoom: 10,
			format: 'image/png',
			attribution: '<a href=\'http://www.sedecatastro.gob.es/\' target=\'_blank\'>Spanish General Directorate for Cadastre</a>'
		},
		variants: {
			Catastro: {
				url: 'https://ovc.catastro.meh.es/Cartografia/WMS/ServidorWMS.aspx',
				options: {
					layers: 'Catastro',
					version: '1.1.1',
					minZoom: 1,
					transparent: false
				}
			},
			Parcela: {
				url: 'https://ovc.catastro.meh.es/Cartografia/WMS/ServidorWMS.aspx',
				options: {
					layers: 'PARCELA',
					version: '1.1.1',
					minZoom: 15
				}
			},
			CadastralParcel: 'CP.CadastralParcel',
			CadastralZoning: 'CP.CadastralZoning',
			Address: 'AD.Address',
			Building: 'BU.Building',
			BuildingPart: 'BU.BuildingPart',
			AdministrativeBoundary: 'AU.AdministrativeBoundary',
			AdministrativeUnit: 'AU.AdministrativeUnit'

		}
	},
	RedTransporte: {
		url: 'https://servicios.idee.es/wms-inspire/transportes',
		options: {
			layers: 'TN.RoadTransportNetwork.RoadLink',
			version: '1.3.0',
			transparent: true,
			format: 'image/png',
			attribution: 'Sistema Geogr&aacute;fico Nacional <a href=\'http://www.scne.es\'>SCNE</a>'
		},
		variants: {
			// Selected, there are more, feel free to contribute
			Carreteras: {},
			Ferroviario: 'TN.RailTransportNetwork.RailwayLink',
			Aerodromo: 'TN.AirTransportNetwork.AerodromeArea',
			Pistas: 'TN.AirTransportNetwork.RunwayArea',
			CallesRodaje: 'TN.AirTransportNetwork.TaxiwayArea',
			Plataformas: 'TN.AirTransportNetwork.ApronArea',
			TransporteCable: 'TN.CableTransportNetwork.CablewayLink',
			AreaServicio: 'TN.RoadTransportNetwork.RoadServiceArea',
			EstacionesFerroviario: 'TN.RailTransportNetwork.RailwayStationArea',
			Puertos: 'TN.WaterTransportNetwork.PortArea'
		}
	},
	Cartociudad: {
		url: 'https://www.cartociudad.es/wms-inspire/direcciones-ccpp?',
		options: {
			attribution: 'CC BY 4.0 scne.es <a href=\'http://www.cartociudad.es\'>Cartociudad</a>',
			layers: 'codigo-postal',
			version: '1.3.0',
			transparent: true,
			minZoom: 11,
			format: 'image/png'
		},
		variants: {
			CodigosPostales: {},
			Direcciones: {
				options: {
					layers: 'AD.Address',
					minZoom: 17
				}
			}
		}
	},
	NombresGeograficos: {
		url: 'https://www.ign.es/wms-inspire/ngbe?',
		options: {
			layers: 'GN.GeographicalNames',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: '{attribution.IGNBase}',
			minZoom: 6
		}
	},
	UnidadesAdm: {
		url: 'https://www.ign.es/wms-inspire/unidades-administrativas?',
		options: {
			layers: 'AU.AdministrativeBoundary',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: '{attribution.IGNBase}'
		},
		variants: {
			Limites: 'AU.AdministrativeBoundary',
			LimitesHistoricos: 'LimitesHistoricos',
			Unidades: 'AU.AdministrativeUnit'
		}
	},
	Hidrografia: {
		url: 'https://servicios.idee.es/wms-inspire/hidrografia?',
		options: {
			layers: 'HY.PhysicalWaters.Waterbodies',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: 'CC BY 4.0 scne.es <a href=\'scne.es\'>SCNE</a>'
		},
		// Selected, there are more, feel free to contribute
		variants: {
			MasaAgua: {},
			Cuencas: 'HY.PhysicalWaters.Catchments',
			Subcuencas: {
				url: 'https://gis.miteco.gob.es/geoserver/agua/subcuencas/wms?',
				options: {
					attribution: 'Ministerio para la Transici&oacute;n Ecol&oacute;gica y el Reto Demogr&aacute;fico',
					layers: 'subcuencas'
				}
			},
			POI: 'HY.PhysicalWaters.HydroPointOfInterest',
			ManMade: {
				options: {
					minZoom: 10,
					layers: 'HY.PhysicalWaters.ManMadeObject'
				}
			},
			LineaCosta: 'HY.PhysicalWaters.LandWaterBoundary',
			Rios: {
				options: {
					layers: 'HY.Network',
					minZoom: 6
				}
			},
			Humedales: 'HY.PhysicalWaters.Wetland'
		}
	},
	Militar: {
		url: 'https://wms-defensa.idee.es/mapas?',
		options: {
			layers: 'CEGET_1M',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: 'Centro Geogr&aacute;fico del Ej&eacute;rcito de Tierra (CEGET)'
		},
		variants: {
			CEGET1M: {},
			CEGETM7814: 'CEGET_M7814',
			CEGETM7815: 'CEGET_M7815',
			CEGETM682: 'ceget_M682',
			CECAF1M: 'cecaf_cnv_1M'
		}
	},
	ADIF: {
		url: 'http://ideadif.adif.es/services/wms?',
		options: {
			layers: 'TN.RailTransportNetwork.RailwayLink',
			format: 'image/png',
			transparent: true,
			attribution: '&copy; ADIF'
		},
		variants: {
			Vias: {},
			Nodos: 'TN.RailTransportNetwork.RailwayNode',
			Estaciones: 'TN.RailTransportNetwork.RailwayStationNode'
		}
	},
	LimitesMaritimos: {
		url: 'https://ideihm.covam.es/ihm-inspire/wms-unidadesmaritimas?',
		options: {
			layers: 'AU.MaritimeBoundary',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: '&copy; Instituto Hidrogr&aacute;fico de la Marina'
		},
		variants: {
			LimitesMaritimos: {},
			LineasBase: 'AU.Baseline'
		}
	},
	Copernicus: {
		url: 'https://image.discomap.eea.europa.eu/arcgis/services/GioLandPublic/HRL_TreeCoverDensity_2015/MapServer/WMSServer?',
		options: {
			layers: '0,1',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: 'European Union&#39;s <a href=\'https://land.copernicus.eu/\'>Copernicus Land Monitoring Service</a> information'
		},
		variants: {
			Forest: {},
			ForestLeaf: {
				url: 'https://image.discomap.eea.europa.eu/arcgis/services/GioLandPublic/HRL_DominantLeafType_2015/ImageServer/WMSServer?',
				options: {
					layers: 'HRL_DominantLeafType_2015',
					crs: L.CRS.EPSG4326
				}
			},
			WaterWet: {
				url: 'https://image.discomap.eea.europa.eu/arcgis/services/GioLandPublic/HRL_WaterWetness_2015/MapServer/WMSServer?'
			},
			SoilSeal: {
				url: 'https://image.discomap.eea.europa.eu/arcgis/services/GioLandPublic/HRL_ImperviousnessDensity_2015/MapServer/WMSServer?'
			},
			GrassLand: {
				url: 'https://image.discomap.eea.europa.eu/arcgis/services/GioLandPublic/HRL_Grassland_2015/MapServer/WMSServer?'
			},
			RiparianLandCover: {
				url: 'https://copernicus.discomap.eea.europa.eu/arcgis/services/RiparianZones/RZ_2012/MapServer/WMSServer?',
				options: {
					layers: '0,1'
				}
			},
			Natura2k: {
				url: 'https://copernicus.discomap.eea.europa.eu/arcgis/services/Natura2000/N2K_2012/MapServer/WMSServer?',
				options: {
					layers: '0,1'
				}
			},
			UrbanAtlas: {
				url: 'https://image.discomap.eea.europa.eu/arcgis/services/UrbanAtlas/UA_UrbanAtlas_2012/MapServer/WMSServer?',
				options: {
					layers: 'Land_Use_Raster1402,Land_Use_vector52160',
					minZoom: 8
				}
			},
			RiparianGreen: {
				url: 'https://servicios.idee.es/wms/copernicus-landservice-spain?',
				deprecated: 'Copernicus.RiparianGreen is deprecated. The IGN service is unavailable and no equivalent official WMS has been identified.',
				options: {
					layers: 'Copernicus_RZ_GLE',
					version: '1.1.1',
					attribution: '{attribution.IGNBase}'
				}
			}
		}
	},
	PNOAHistorico: {
		url: 'https://www.ign.es/wms/pnoa-historico?',
		options: {
			attribution: '{attribution.IGNBase}',
			layers: 'AMS_1956-1957',
			version: '1.3.0',
			format: 'image/png',
			transparent: false
		},
		variants: {
			Americano: 'AMS_1956-1957',
			Interministerial: 'Interministerial_1973-1986',
			Nacional: 'Nacional_1981-1986',
			OLISTAT: 'OLISTAT',
			SIGPAC: 'SIGPAC',
			PNOA2004: 'PNOA2004',
			PNOA2009: 'PNOA2009',
			PNOA2014: 'PNOA2014',
			PNOA2019: 'PNOA2019',
			PNOA2024: 'PNOA2024'
		}
	},
	MTNHistorico: {
		url: 'https://www.ign.es/wmts/primera-edicion-mtn?service=WMTS&request=GetTile&version=1.0.0&Format=image/jpeg&layer={variant}&style=default&tilematrixset=GoogleMapsCompatible&TileMatrix={z}&TileRow={y}&TileCol={x}',
		options: {
			attribution: '{attribution.IGNBase}',
			variant: 'mtn50-edicion1',
			maxNativeZoom: 19
		},
		variants: {
			MTN50: 'mtn50-edicion1',
			MTN25: 'mtn25-edicion1',
			Minutas: 'catastrones'
		}
	},
	Inundaciones: {
		url: 'https://servicios.idee.es/wms-inspire/riesgos-naturales/inundaciones?',
		options: {
			attribution: 'MITECO',
			layers: 'NZ.Flood.FluvialT10',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			FluvialT10: 'NZ.Flood.FluvialT10',
			FluvialT100: 'NZ.Flood.FluvialT100',
			FluvialT500: 'NZ.Flood.FluvialT500',
			MarinaT100: 'NZ.Flood.MarinaT100',
			MarinaT500: 'NZ.Flood.MarinaT500'
		}
	},
	RedNatura: {
		url: 'https://iepnb.gob.es/geoserver/RN2000/rn2000/wms?',
		options: {
			attribution: 'MITECO',
			layers: 'rn2000',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			General: 'rn2000'
		}
	},
	EspaciosProtegidos: {
		url: 'https://iepnb.gob.es/geoserver/ENP/enp/wms?',
		options: {
			attribution: 'MITECO',
			layers: 'enp',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			General: 'enp'
		}
	},
	SeccionesINE: {
		url: 'https://servicios.ine.es/arcgis/services/WMS_INE_SECCIONES_G01/MapServer/WMSServer?',
		options: {
			attribution: 'Instituto Nacional de Estad&iacute;stica (INE)',
			layers: 'Secciones2026',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Secciones2026: 'Secciones2026',
			Distritos2026: 'Distritos2026',
			Secciones2021: 'Secciones2021',
			Distritos2021: 'Distritos2021'
		}
	},
	Pendientes: {
		url: 'https://wms-pendientes.idee.es/pendientes?',
		options: {
			attribution: '{attribution.IGNBase}',
			layers: 'MDP05',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			MDP05: 'MDP05'
		}
	},
	GEODE: {
		url: 'https://mapas.igme.es/gis/services/Cartografia_Geologica/IGME_Geode_50/MapServer/WMSServer?',
		options: {
			attribution: 'IGME-CSIC',
			layers: '1,2,3,4,5,6,9',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Geologia: '1,2,3,4,5,6,9',
			Unidades: '1',
			Contactos: '2',
			Cuaternario: '3'
		}
	},
	SIGPAC: {
		url: 'https://sigpac-hubcloud.es/wms?',
		options: {
			attribution: 'FEGA / MAPA',
			layers: 'AU.Sigpac:recinto',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Recintos: 'AU.Sigpac:recinto',
			CultivoDeclarado2025: 'AU.Sigpac:cultivo_declarado',
			PaisajeAreas: 'AU.Sigpac:e_paisaje',
			PaisajeLineas: 'AU.Sigpac:e_paisaje_linea',
			PaisajePuntos: 'AU.Sigpac:e_paisaje_punto'
		}
	},
	MapaForestal: {
		url: 'https://iepnb.gob.es/geoserver/foto_fija_mfe/ff_uso/wms?',
		options: {
			attribution: 'MITECO',
			layers: 'ff_uso',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Usos: 'ff_uso'
		}
	},
	Planimetrias: {
		url: 'https://www.ign.es/wmts/minutas-cartograficas?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}&style=default&tilematrixset=GoogleMapsCompatible&TileMatrix={z}&TileRow={y}&TileCol={x}',
		options: {
			attribution: '{attribution.IGNBase}',
			variant: 'Minutas',
			maxNativeZoom: 20
		},
		variants: {
			Minutas: 'Minutas'
		}
	},
	CaminosNaturales: {
		url: 'https://wms.mapama.gob.es/sig/desarrollorural/ccnn_etapas?',
		options: {
			attribution: 'MAPA',
			layers: 'ccnn_etapas',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Etapas: 'ccnn_etapas'
		}
	},
	SpainByBike: {
		url: 'https://wms-spainbybike.idee.es/spainbybike?',
		options: {
			attribution: '{attribution.IGNBase}',
			layers: 'etapas',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Etapas: 'etapas',
			TiposVia: 'tipo_via',
			CentrosBTT: 'centros_btt',
			Puertos: 'puertos_linea',
			PuertosPuntos: 'puertos_pto'
		}
	},
	ViasPecuarias: {
		url: 'https://iepnb.gob.es/geoserver/vias_pecuarias/rgvp_2024/wms?',
		options: {
			attribution: 'MITECO',
			layers: 'rgvp_2024',
			version: '1.3.0',
			format: 'image/png',
			transparent: true
		},
		variants: {
			Red2024: 'rgvp_2024'
		}
	},
	PotencialSolar: {
		url: 'https://wmts-potencial-solar.idee.es/potencial-solar?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}&style=default&tilematrixset=GoogleMapsCompatible&TileMatrix={z}&TileRow={y}&TileCol={x}',
		options: {
			attribution: '{attribution.IGNBase}',
			variant: 'potencial-solar-global',
			maxNativeZoom: 20
		},
		variants: {
			Global: 'potencial-solar-global',
			Edificios: 'potencial-solar'
		}
	},
	ParquesNaturales: {
		url: 'https://sigred.oapn.es/geoserverOAPN/LimitesParquesNacionalesZPP/ows?',
		options: {
			layers: 'view_red_oapn_limite_pn',
			version: '1.3.0',
			format: 'image/png',
			transparent: true,
			attribution: 'Ministerio para la Transici&oacute;n Ecol&oacute;gica y el Reto Demogr&aacute;fico'
		},
		variants: {
			Limites: {},
			ZonasPerifericas: 'view_red_oapn_zpp'
		}
	}
};
// Adapted from https://github.com/leaflet-extras/leaflet-providers
// Copyright (c) 2013 Leaflet Providers contributors All rights reserved.
// BSD 2-Clause "Simplified" License
function providerOpts(arg, options) {
	// Copy catalog data while preserving Leaflet instances and CRS identity.
	function copyCatalogValue(value) {
		if (Array.isArray(value)) {
			return value.map(copyCatalogValue);
		}
		if (value && typeof value === 'object') {
			var prototype = Object.getPrototypeOf(value);
			if (prototype !== null && Object.getPrototypeOf(prototype) !== null) {
				return value;
			}
			var copy = {};
			Object.keys(value).forEach(function(key) {
				copy[key] = key === 'crs'
					? value[key]
					: copyCatalogValue(value[key]);
			});
			return copy;
		}
		return value;
	}
	var providers = providersESP;
	var parts = arg.split('.');
	var providerName = parts[0];
	var variantName = parts[1];
	if (!providers[providerName]) {
		throw 'No such provider (' + providerName + ')';
	}
	var provider = {
		url: providers[providerName].url,
		options: copyCatalogValue(providers[providerName].options)
	};
	if (variantName) {
		provider.options.providerName = providerName + '.' + variantName;
	} else {
		provider.options.providerName = providerName;
	}
	// overwrite values in provider from variant.
	if (variantName && 'variants' in providers[providerName]) {
		if (!(variantName in providers[providerName].variants)) {
			throw 'No such variant of ' + providerName + ' (' + variantName + ')';
		}
		var variant = providers[providerName].variants[variantName];
		// Guess WMS or WMTS
		var finalurl = variant.url || provider.url;
		// According to template Tiles uses {x} while WMS not.
		var wmts = finalurl.includes('{x}');
		var variantOptions;
		if (typeof variant === 'string') {
			// Depending on WMTS or Tiles
			if (wmts) {
				variantOptions = {
					variant: variant
				};
			} else {
				variantOptions = {
					layers: variant
				};
			}
		} else {
			variantOptions = variant.options;
		}
		provider = {
			url: variant.url || provider.url,
			options: L.Util.extend({}, provider.options, copyCatalogValue(variantOptions))
		};
	}
	// replace attribution placeholders with their values from toplevel provider attribution,
	// recursively
	function attributionReplacer(attr) {
		if (attr.indexOf('{attribution.') === -1) {
			return attr;
		}
		return attr.replace(/\{attribution.(\w*)\}/g, function(match, attributionName) {
			return attributionReplacer(providers[attributionName].options.attribution);
		});
	}
	provider.options.attribution = attributionReplacer(provider.options.attribution);
	// Compute final options combining provider options with any user overrides
	var layerOpts = L.Util.extend({}, provider.options, options);
	var providerend = {
		url: provider.url,
		options: layerOpts
	};
	return providerend;
}
var warnedDeprecatedProvidersESP = {};
L.tileLayer.providerESP = function(name, opts) {
	var newprov = providerOpts(name, opts);
	var parts = name.split('.');
	var variants = providersESP[parts[0]].variants;
	var variant = variants && variants[parts[1]];
	if (variant && variant.deprecated && !warnedDeprecatedProvidersESP[name] &&
	  typeof console !== 'undefined' && typeof console.warn === 'function') {
		console.warn(variant.deprecated);
		warnedDeprecatedProvidersESP[name] = true;
	}
	var nameurl = newprov.url;
	if (nameurl.includes('{x}')) {
		return L.tileLayer(newprov.url, newprov.options);
	} else {
		return L.tileLayer.wms(newprov.url, newprov.options);
	}
};
