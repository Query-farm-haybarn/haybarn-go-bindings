# Haybarn: static-lib archives are fetched from the Haybarn engine's GitHub
# Releases (Query-farm-haybarn/haybarn), produced by its BundleStaticLibs
# workflow. The asset filenames (static-libs-osx-arm64.zip, ...) are identical
# to upstream DuckDB's, so only the owner/repo/tag below differ. The archives
# carry libhaybarn_static.a (the engine, with the Haybarn extension trust root
# and haybarn-extensions.query.farm URLs baked in) plus the unchanged extension
# and third-party archives.
HAYBARN_REPO=Query-farm-haybarn/haybarn
HAYBARN_VERSION=haybarn-v1.5.4-rc2

fetch.static.libs:
	cd lib/${PLATFORM} && \
	curl -OL https://github.com/${HAYBARN_REPO}/releases/download/${HAYBARN_VERSION}/${FILENAME}.zip && \
	rm -f *.a duckdb.h && \
	unzip ${FILENAME}.zip && \
	rm -f ${FILENAME}.zip && \
	if [ -n "${COPY_HEADER}" ]; then cp duckdb.h ../../include/; fi

test.dynamic.lib:
	mkdir dynamic-dir && \
	cd dynamic-dir && \
	curl -OL https://github.com/${HAYBARN_REPO}/releases/download/${HAYBARN_VERSION}/${FILENAME}.zip && \
	unzip ${FILENAME}.zip
