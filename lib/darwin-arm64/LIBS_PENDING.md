# Static libraries pending

The Haybarn static-library archives for `darwin-arm64` are fetched from a Haybarn engine
release, not committed by hand and not carried over from upstream DuckDB.

Populate them with:

    make fetch.static.libs PLATFORM=darwin-arm64 FILENAME=<asset-name>

(see ../../Makefile and ../../.github/workflows/fetch.yml). Until then, cgo
builds for this platform will not link. This file is removed/ignored once the
real `.a` archives are in place.
