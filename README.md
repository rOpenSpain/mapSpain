# mapSpain CDN for SIANE data

This branch is used as CDN to distribute SIANE data to `mapSpain`.

Due to poor API, data is not easily reachable, so this branch would be used as API endpoint.

Latest data downloaded correspond to **2020**.

## Structure

Data is available under `data-raw/YYYY`. Both zipped and unzipped versions are provided.

### Improvement

Convert data to `.gpkg` before distributing for easy access.