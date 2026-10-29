# Rebuild from the vendored leaflet-providersESP release (requires V8 and xml2).
# Source: https://github.com/dieghernan/leaflet-providersESP/tree/v1.4.0/dist
ctx <- V8::v8()
ctx$eval(
  "var L = {CRS: {EPSG4326: 'EPSG:4326'}, Util: {extend: Object.assign}, tileLayer: {}};"
)
ctx$source("data-raw/input/leaflet-providers.js")
ctx$eval(
  "var catalog = {}; Object.keys(providersESP).forEach(function(name) {
  var names = [name].concat(Object.keys(providersESP[name].variants || {})
    .map(function(variant) { return name + '.' + variant; }));
  names.forEach(function(id) { catalog[id] = providerOpts(id); });
});"
)
catalog <- ctx$get("catalog")

esp_tiles_providers <- lapply(catalog, function(provider) {
  opts <- provider$options
  url <- provider$url
  for (key in names(opts)) {
    placeholder <- paste0("{", key, "}")
    if (grepl(placeholder, url, fixed = TRUE)) {
      url <- gsub(placeholder, as.character(opts[[key]]), url, fixed = TRUE)
    }
  }
  attribution <- xml2::xml_text(xml2::read_html(paste0(
    "<p>",
    opts$attribution,
    "</p>"
  )))
  if (grepl("{x}", url, fixed = TRUE)) {
    parts <- strsplit(url, "?", fixed = TRUE)[[1]]
    static <- list(attribution = attribution, q = parts[1])
    if (length(parts) > 1L) {
      static$q <- paste0(static$q, "?")
      params <- strsplit(parts[2], "&", fixed = TRUE)[[1]]
      for (param in params) {
        key <- tolower(sub("=.*", "", param))
        static[[key]] <- sub("^[^=]*=", "", param)
      }
    }
    opts <- opts[intersect(
      names(opts),
      c("attribution", "minZoom", "maxNativeZoom")
    )]
  } else {
    version <- opts$version
    if (is.null(version)) {
      version <- "1.3.0"
    }
    crs <- opts$crs
    if (is.null(crs)) {
      crs <- "EPSG:3857"
    }
    static <- list(
      attribution = attribution,
      q = paste0(sub("\\?+$", "", url), "?"),
      service = "WMS",
      version = version,
      request = "GetMap",
      format = opts$format,
      transparent = tolower(as.character(opts$transparent)),
      layers = opts$layers
    )
    static[[if (version >= "1.3.0") "crs" else "srs"]] <- crs
    static <- c(static, list(width = "512", height = "512", bbox = "{bbox}"))
    static$styles <- if (is.null(opts$styles)) "" else opts$styles
    opts <- opts[intersect(names(opts), c("attribution", "minZoom", "crs"))]
  }
  list(static = static, leaflet = opts)
})
usethis::use_data(esp_tiles_providers, overwrite = TRUE)
