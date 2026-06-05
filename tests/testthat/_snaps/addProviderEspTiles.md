# Testing leaflet

    Code
      puertadelsol <- addProviderEspTiles(setView(leaflet(), lat = 40.4166, lng = -
      3.70384, zoom = 18), provider = "TESTING")
    Condition
      Error:
      ! `provider` must be "IDErioja", "IDErioja.Base", "IDErioja.Relieve", "IDErioja.Claro", "IDErioja.Oscuro", "IGNBase", "IGNBase.Todo", "IGNBase.Gris", "IGNBase.TodoNoFondo", "IGNBase.Orto", "MDT", "MDT.Elevaciones", "MDT.Relieve", "MDT.CurvasNivel", "MDT.SpotElevation", "PNOA", "PNOA.MaximaActualidad", "PNOA.Mosaico", ..., "ParquesNaturales.Limites", or "ParquesNaturales.ZonasPerifericas", not "TESTING".

