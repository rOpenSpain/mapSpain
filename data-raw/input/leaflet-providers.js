// leaflet-providersESP.js plugin v1.3.2
// (c) D. Hernangomez - MIT License
// https://dieghernan.github.io/leaflet-providersESP/
// Issues: https://dieghernan.github.io/leaflet-providersESP/issues
// All providers are open source. Please check attributions
// Feel free to contribute
"use strict";
var providersESPversion = 'v1.3.2';
// Databases
// WMTS Servers - Tile Maps - Mapas de Teselas
var completeWMTS = "&style=default&tilematrixset=GoogleMapsCompatible&TileMatrix={z}&TileRow={y}&TileCol={x}";
var providersESP = {
  IDErioja: {
    url: "https://rts.larioja.org/wmts/mapa_base_rioja?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer=mapa_base_rioja" + completeWMTS,
    options: {
      attribution: "CC BY 4.0 <a href='https://www.iderioja.org'>www.iderioja.org</a>"
    }
  },
  // IGN Mapa Base
  IGNBase: {
    url: "https://www.ign.es/wmts/ign-base?service=WMTS&request=GetTile&version=1.0.0&Format=image/{ext}&layer={variant}" + completeWMTS,
    options: {
      attribution: "CC BY 4.0 scne.es. Sistema Geogr&aacute;fico Nacional <a href='http://www.ign.es'>IGN</a> ",
      variant: "IGNBaseTodo",
      ext: "png"
    },
    variants: {
      Todo: "IGNBaseTodo",
      Gris: {
        options: {
          variant: "IGNBase-gris",
          ext: "jpeg"
        }
      },
      TodoNoFondo: {
        options: {
          variant: "IGNBaseTodo-nofondo",
          bounds: [
            [27, -19],
            [44, 5]
          ],
          minZoom: 4
        }
      },
      Orto: {
        options: {
          variant: "IGNBaseOrto",
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
    url: "https://servicios.idee.es/wmts/mdt?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}" + completeWMTS,
    options: {
      attribution: "<a href='http://www.ign.es/'>Infraestructura de Datos Espaciales de Espa&ntilde;a (IDEE)</a>",
      variant: "EL.ElevationGridCoverage",
      bounds: [
        [22.173559281306314, -47.0716243806546],
        [66.88067635831743,
          40.8749629405498
        ]
      ]
    },
    variants: {
      Elevaciones: {},
      Relieve: "Relieve",
      CurvasNivel: {
        url: "https://servicios.idee.es/wms-inspire/mdt?",
        options: {
          layers: "EL.ContourLine",
          transparent: true,
          format: "image/png",
          minZoom: 12
        }
      },
      SpotElevation: {
        url: "https://servicios.idee.es/wms-inspire/mdt?",
        options: {
          layers: "EL.SpotElevation",
          transparent: true,
          format: "image/png",
          minZoom: 14
        }
      }
    }
  },
  // Plan Nacional de Ortofotografia Aerea
  PNOA: {
    url: "https://www.ign.es/wmts/pnoa-ma?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer=OI.OrthoimageCoverage" + completeWMTS,
    options: {
      attribution: "{attribution.MDT}",
      minZoom: 4,
      bounds: [
        [22.173559281306314, -47.0716243806546],
        [66.88067635831743,
          40.8749629405498
        ]
      ]
    },
    variants: {
      MaximaActualidad: {},
      Mosaico: {
        url: "http://www.ign.es/wms-inspire/pnoa-ma?",
        options: {
          layers: "OI.MosaicElement",
          format: "image/png",
          transparent: true
        }
      }
    }
  },
  // Ocupacion Suelo
  OcupacionSuelo: {
    url: "https://servicios.idee.es/wmts/ocupacion-suelo?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}&style=default" + completeWMTS,
    options: {
      attribution: "CC BY 4.0 scne.es. <a href='http://www.ign.es/'>Infraestructura de Datos Espaciales de Espa&ntilde;a (IDEE)</a>",
      variant: "LC.LandCoverSurfaces"
    },
    variants: {
      Ocupacion: {},
      Usos: "LU.ExistingLandUse"
    }
  },
  // Light Detection and Ranging - LiDAR
  LiDAR: {
    url: "https://wmts-mapa-lidar.idee.es/lidar?service=WMTS&request=GetTile&version=1.0.0&Format=image/png&layer={variant}" + completeWMTS,
    options: {
      attribution: "{attribution.MDT}",
      variant: "EL.GridCoverageDSM"
    }
  },
  // Mapa Topografico Nacional
  MTN: {
    url: "https://ign.es/wmts/mapa-raster?service=WMTS&request=GetTile&version=1.0.0&Format=image/jpeg&layer=MTN&style=default" + completeWMTS,
    options: {
      attribution: "{attribution.MDT}",
      minZoom: 4,
      bounds: [
        [22.173559281306314, -47.0716243806546],
        [66.88067635831743,
          40.8749629405498
        ]
      ]
    }
  },
  //WMS Servers
  Geofisica: {
    url: "https://www.ign.es/wms-inspire/geofisica?",
    options: {
      layers: "Ultimos10dias",
      format: "image/png",
      transparent: true,
      attribution: "{attribution.IGNBase}"
    },
    // Selected
    variants: {
      Terremotos10dias: {},
      Terremotos30dias: "Ultimos30dias",
      Terremotos365dias: "Ultimos365dias",
      ObservedEvents: "NZ.ObservedEvent",
      HazardArea: "NZ.HazardArea"
    }
  },
  VigilanciaVolcanica: {
    url: "https://wms-volcanologia.ign.es/volcanologia?",
    options: {
      layers: "erupciones",
      format: "image/png",
      transparent: true,
      attribution: "{attribution.IGNBase}"
    },
    // Selected
    variants: {
      ErupcionesHistoricas: {}
    }
  },
  CaminoDeSantiago: {
    url: "https://www.ign.es/wms-inspire/camino-santiago?",
    options: {
      layers: "camino_frances",
      format: "image/png",
      transparent: true,
      attribution: "CC BY 4.0 <a href='https://www.ign.es'>ign.es</a>. Federaci&oacute;n Espa&ntilde;ola de Asociaciones de Amigos del Camino de Santiago (FEAACS)"
    },
    variants: {
      CaminoFrances: {},
      CaminosFrancia: "caminos_francia",
      CaminosGalicia: "caminos_galicia",
      CaminosDelNorte: "caminos_norte",
      CaminosAndaluces: "caminos_andaluces",
      CaminosCentro: "caminos_centro",
      CaminosEste: "caminos_este",
      CaminosCatalanes: "caminos_catalanes",
      CaminosSureste: "caminos_sureste",
      CaminosInsulares: "caminos_insulares",
      CaminosPortugueses: "caminos_portugueses"
    }
  },
  Catastro: {
    url: "https://ovc.catastro.meh.es/cartografia/INSPIRE/spadgcwms.aspx",
    options: {
      layers: "CP.CadastralParcel",
      transparent: true,
      minZoom: 10,
      format: "image/png",
      attribution: "<a href='http://www.sedecatastro.gob.es/' target='_blank'>Spanish General Directorate for Cadastre</a>"
    },
    variants: {
      Catastro: {
        url: "http://ovc.catastro.meh.es/Cartografia/WMS/ServidorWMS.aspx",
        options: {
          layers: "Catastro",
          minZoom: 1,
          transparent: false
        }
      },
      Parcela: {
        url: "http://ovc.catastro.meh.es/Cartografia/WMS/ServidorWMS.aspx",
        options: {
          layers: "PARCELA",
          minZoom: 15
        }
      },
      CadastralParcel: "CP.CadastralParcel",
      CadastralZoning: "CP.CadastralZoning",
      Address: "AD.Address",
      Building: "BU.Building",
      BuildingPart: "BU.BuildingPart",
      AdministrativeBoundary: "AU.AdministrativeBoundary",
      AdministrativeUnit: "AU.AdministrativeUnit"

    }
  },
  RedTransporte: {
    url: "https://servicios.idee.es/wms-inspire/transportes",
    options: {
      layers: "TN.RoadTransportNetwork.RoadLink",
      transparent: true,
      format: "image/png",
      attribution: "Sistema Geogr&aacute;fico Nacional <a href='http://www.scne.es'>SCNE</a>"
    },
    variants: {
      // Selected, there are more, feel free to contribute
      Carreteras: {},
      Ferroviario: "TN.RailTransportNetwork.RailwayLink",
      Aerodromo: "TN.AirTransportNetwork.AerodromeArea",
      AreaServicio: "TN.RoadTransportNetwork.RoadServiceArea",
      EstacionesFerroviario: "TN.RailTransportNetwork.RailwayStationArea",
      Puertos: "TN.WaterTransportNetwork.PortArea"
    }
  },
  Cartociudad: {
    url: "https://www.cartociudad.es/wms-inspire/direcciones-ccpp?",
    options: {
      attribution: "CC BY 4.0 scne.es <a href='http://www.cartociudad.es'>Cartociudad</a>",
      layers: "codigo-postal",
      transparent: true,
      minZoom: 14,
      format: "image/png"
    },
    variants: {
      CodigosPostales: {},
      Direcciones: {
        options: {
          layers: "AD.Address",
          minZoom: 15
        }
      }
    }
  },
  NombresGeograficos: {
    url: "https://www.ign.es/wms-inspire/ngbe?",
    options: {
      layers: "GN.GeographicalNames",
      format: "image/png",
      transparent: true,
      attribution: "{attribution.IGNBase}",
      minZoom: 6
    }
  },
  UnidadesAdm: {
    url: "https://www.ign.es/wms-inspire/unidades-administrativas?",
    options: {
      layers: "AU.AdministrativeBoundary",
      format: "image/png",
      transparent: true,
      attribution: "{attribution.IGNBase}"
    },
    variants: {
      Limites: "AU.AdministrativeBoundary",
      Unidades: "AU.AdministrativeUnit"
    }
  },
  Hidrografia: {
    url: "https://servicios.idee.es/wms-inspire/hidrografia?",
    options: {
      layers: "HY.PhysicalWaters.Waterbodies",
      format: "image/png",
      transparent: true,
      attribution: "CC BY 4.0 scne.es <a href='scne.es'>SCNE</a>"
    },
    // Selected, there are more, feel free to contribute
    variants: {
      MasaAgua: {},
      Cuencas: "HY.PhysicalWaters.Catchments",
      Subcuencas: {
        url: "https://wms.mapama.gob.es/sig/Agua/SubcuencasCauces/wms.aspx?",
        options: {
          attribution: "Ministerio para la Transici&oacute;n Ecol&oacute;gica y el Reto Demogr&aacute;fico",
          layers: "HY.PhysicalWaters.Catchments"
        }
      },
      POI: "HY.PhysicalWaters.HydroPointOfInterest",
      ManMade: {
        options: {
          minZoom: 10,
          layers: "HY.PhysicalWaters.ManMadeObject"
        }
      },
      LineaCosta: "HY.PhysicalWaters.LandWaterBoundary",
      Rios: {
        options: {
          layers: "HY.Network",
          minZoom: 6
        }
      },
      Humedales: "HY.PhysicalWaters.Wetland"
    }
  },
  Militar: {
    url: "http://wms-defensa.idee.es/mapas?",
    options: {
      layers: "CEGET_1M",
      format: "image/png",
      transparent: true,
      attribution: "Centro Geogr&aacute;fico del Ej&eacute;rcito de Tierra (CEGET)"
    },
    variants: {
      CEGET1M: {},
      CEGETM7814: "CEGET_M7814",
      CEGETM7815: "CEGET_M7815",
      CEGETM682: "ceget_M682",
      CECAF1M: "cecaf_cnv_1M"
    }
  },
  ADIF: {
    url: "http://ideadif.adif.es/services/wms?",
    options: {
      layers: "TN.RailTransportNetwork.RailwayLink",
      format: "image/png",
      transparent: true,
      attribution: "&copy; ADIF"
    },
    variants: {
      Vias: {},
      Nodos: "TN.RailTransportNetwork.RailwayNode",
      Estaciones: "TN.RailTransportNetwork.RailwayStationNode"
    }
  },
  LimitesMaritimos: {
    url: "http://ideihm.covam.es/ihm-inspire/wms-unidadesmaritimas?",
    options: {
      layers: "AU.MaritimeBoundary",
      format: "image/png",
      transparent: true,
      attribution: "&copy; Instituto Hidrogr&aacute;fico de la Marina"
    },
    variants: {
      LimitesMaritimos: {},
      LineasBase: "AU.Baseline"
    }
  },
  Copernicus: {
    url: "https://servicios.idee.es/wms/copernicus-landservice-spain?",
    options: {
      layers: "HRLForestTCD2015",
      format: "image/png",
      transparent: true,
      attribution: "{attribution.IGNBase}"
    },
    variants: {
      Forest: {},
      ForestLeaf: "HRLForestDLT2015",
      WaterWet: "HRLWaterWetT2015",
      SoilSeal: "HRLImpervioDens2015",
      GrassLand: "HRLGrassLand2015",
      RiparianGreen: "Copernicus_RZ_GLE",
      RiparianLandCover: "Copernicus_RZ_LCLU",
      Natura2k: "N2k_LCLU_2012",
      UrbanAtlas: {
        options: {
          layers: "Urban_Atlas_2012",
          minZoom: 8
        }
      }
    }
  },
  ParquesNaturales: {
    url: "http://sigred.oapn.es/geoserverOAPN/LimitesParquesNacionalesZPP/ows?",
    options: {
      layers: "view_red_oapn_limite_pn",
      format: "image/png",
      transparent: true,
      attribution: "Ministerio para la Transici&oacute;n Ecol&oacute;gica y el Reto Demogr&aacute;fico"
    },
    variants: {
      Limites: {},
      ZonasPerifericas: "view_red_oapn_zpp"
    }
  }
};
// Adapted from https://github.com/leaflet-extras/leaflet-providers
// Copyright (c) 2013 Leaflet Providers contributors All rights reserved.
// BSD 2-Clause "Simplified" License
function providerOpts(arg, options) {
  var providers = providersESP;
  var parts = arg.split('.');
  var providerName = parts[0];
  var variantName = parts[1];
  if (!providers[providerName]) {
    throw 'No such provider (' + providerName + ')';
  }
  var provider = {
    url: providers[providerName].url,
    options: providers[providerName].options
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
    //Guess WMS or WMTS
    var finalurl = variant.url || provider.url;
    //According to template Tiles uses {x} while WMS not.
    var wmts = finalurl.includes("{x}");
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
      options: L.Util.extend({}, provider.options, variantOptions)
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
L.tileLayer.providerESP = function(name, opts) {
  var newprov = providerOpts(name, opts);
  var nameurl = newprov.url;
  if (nameurl.includes("{x}")) {
    return L.tileLayer(newprov.url, newprov.options);
  } else {
    return L.tileLayer.wms(newprov.url, newprov.options);
  }
}
