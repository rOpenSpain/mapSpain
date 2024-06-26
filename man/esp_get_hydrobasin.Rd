% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/esp_get_hydrobasin.R
\name{esp_get_hydrobasin}
\alias{esp_get_hydrobasin}
\title{Get \code{\link[sf:sf]{sf}} \code{POLYGON} of the drainage basin demarcations of Spain}
\source{
IGN data via a custom CDN (see
\url{https://github.com/rOpenSpain/mapSpain/tree/sianedata}).
}
\usage{
esp_get_hydrobasin(
  epsg = "4258",
  cache = TRUE,
  update_cache = FALSE,
  cache_dir = NULL,
  verbose = FALSE,
  resolution = "3",
  domain = "land"
)
}
\arguments{
\item{epsg}{projection of the map: 4-digit \href{https://epsg.io/}{EPSG code}.
One of:
\itemize{
\item \code{"4258"}: ETRS89.
\item \code{"4326"}: WGS84.
\item \code{"3035"}: ETRS89 / ETRS-LAEA.
\item \code{"3857"}: Pseudo-Mercator.
}}

\item{cache}{A logical whether to do caching. Default is \code{TRUE}. See
\strong{About caching}.}

\item{update_cache}{A logical whether to update cache. Default is \code{FALSE}.
When set to \code{TRUE} it would force a fresh download of the source file.}

\item{cache_dir}{A path to a cache directory. See \strong{About caching}.}

\item{verbose}{Logical, displays information. Useful for debugging,
default is \code{FALSE}.}

\item{resolution}{Resolution of the \code{POLYGON}. Values available are
\code{"3"}, \code{"6.5"} or \code{"10"}.}

\item{domain}{Possible values are \code{"land"}, that includes only
the ground part or the ground or \code{"landsea"}, that includes both the ground
and the related sea waters of the basin.}
}
\value{
A \code{\link[sf:sf]{sf}} \code{POLYGON} object.
}
\description{
Loads a \code{\link[sf:sf]{sf}} \code{POLYGON} object containing areas with the required
hydrographic elements of Spain.
}
\details{
Metadata available on
\url{https://github.com/rOpenSpain/mapSpain/tree/sianedata/}.
}
\section{About caching}{
You can set your \code{cache_dir} with \code{\link[=esp_set_cache_dir]{esp_set_cache_dir()}}.

Sometimes cached files may be corrupt. On that case, try re-downloading
the data setting \code{update_cache = TRUE}.

If you experience any problem on download, try to download the
corresponding .geojson file by any other method and save it on your
\code{cache_dir}. Use the option \code{verbose = TRUE} for debugging the API query.
}

\examples{
\dontshow{if (esp_check_access()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\donttest{
hydroland <- esp_get_hydrobasin(domain = "land")
hydrolandsea <- esp_get_hydrobasin(domain = "landsea")

library(ggplot2)


ggplot(hydroland) +
  geom_sf(data = hydrolandsea, fill = "skyblue4", alpha = .4) +
  geom_sf(fill = "skyblue", alpha = .5) +
  geom_sf_text(aes(label = rotulo),
    size = 3, check_overlap = TRUE,
    fontface = "bold",
    family = "serif"
  ) +
  coord_sf(
    xlim = c(-9.5, 4.5),
    ylim = c(35, 44)
  ) +
  theme_void()
}
\dontshow{\}) # examplesIf}
}
\seealso{
Other natural: 
\code{\link{esp_get_hypsobath}()},
\code{\link{esp_get_rivers}()}
}
\concept{natural}
