# validate_provider() rejects malformed and unknown providers

    Code
      validate_provider(1)
    Condition
      Error:
      ! `type` must be a named list (see `mapSpain::esp_make_provider()`) or the name of a provider (see `?mapSpain::esp_tiles_providers()`), not a number.

---

    Code
      validate_provider(list(a = 1))
    Condition
      Error:
      ! A custom provider must be a named list with fields id and q. Missing id and q fields. See `mapSpain::esp_make_provider()`.

---

    Code
      validate_provider(list(a = 1, q = "2"))
    Condition
      Error:
      ! A custom provider must be a named list with fields id and q. Missing id field. See `mapSpain::esp_make_provider()`.

---

    Code
      validate_provider("FAKE")
    Condition
      Error:
      ! `type` must be "IDErioja", "IDErioja.Base", "IDErioja.Relieve", "IDErioja.Claro", "IDErioja.Oscuro", "IGNBase", "IGNBase.Todo", "IGNBase.Gris", "IGNBase.TodoNoFondo", "IGNBase.Orto", "MDT", "MDT.Elevaciones", "MDT.Relieve", "MDT.CurvasNivel", "MDT.SpotElevation", "PNOA", "PNOA.MaximaActualidad", "PNOA.Mosaico", ..., "ParquesNaturales.Limites" or "ParquesNaturales.ZonasPerifericas", not "FAKE".

# All built-in tile providers have supported types and CRS

    Code
      unique(prov_type)
    Output
      [1] "WMTS" "WMS" 

---

    Code
      unique(in_epsg)
    Output
      [1] "EPSG:3857"

