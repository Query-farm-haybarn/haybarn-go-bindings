//go:build duckdb_use_lib

package duckdb_go_bindings

/*
#cgo CPPFLAGS: -I${SRCDIR}/include
#cgo LDFLAGS: -lhaybarn
#include <duckdb.h>
*/
import "C"
