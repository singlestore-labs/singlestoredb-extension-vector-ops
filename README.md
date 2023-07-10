# Vector Operations in SingleStoreDB

## Introduction

This module will eventually comprise a set of utility functions intended to fill
functional gaps in the current SingleStoreDB built-in API.

## Contents
Currently, this library provides the following UDFs:

### `vector_pow_f64`
This is a UDF that takes a packed array of doubles and an exponent value.
It computes the corresponding power of each array element and returns the
result in a new packed array of doubles.  The packed arrays are passed in and
out as BLOB objects.  This function is written in MPSQL and wraps the
`vector_pow_f64_helper` function, below.

### `vector_pow_f64_helper`
This is a Wasm UDF which provides the main functionality, however you should
use the wrapper above.  The wrapper works around a current limitation in
SingleStoreDB whereby it is not possible to pass null values to a Wasm
function directly.

## Deployment to SingleStoreDB
There should already be a pre-built Wasm file in the root directory of this
repository, called `extension.wasm`.  If there is not, or you need to rebuild
it, please consult the build steps below.

To install these functions using the MySQL client, use the following commands.
They assume you have built the Wasm module and your current directory is the
root of this Git repo.  Please be sure to replace '$DBUSER`, `$DBHOST`,
`$DBPORT`, and `$DBNAME` with, respectively, your database username, hostname,
port, and the name of the database where you want to deploy the functions.
You will be prompted for a password.
```bash
mysql -u $DBUSER -h $DBHOST -P $DBPORT -D $DBNAME -p < load_extension.sql
```

## Usage Example

This example packs a small JSON array of numbers into a blob, squares each one,
and then unpacks the result into a JSON array.
```sql
select json_array_unpack_f64(vector_pow_f64(json_array_pack_f64('[2, 4, 6]'), 2)) as result;
```
And here is the result:
```console
+-----------+
| result    |
+-----------+
| [4,16,36] |
+-----------+
1 row in set (0.074 sec)
```

## Building

### Compilation

To build this project, you will need to ensure that you have the
[WASI SDK](https://github.com/WebAssembly/wasi-sdk/releases) installed.  Please
set the environment variable `WASI_SDK_PATH` to its top-level directory.

If you change the `extension.wit` file, you will need to regenerate the ABI
wrappers.  To do this, make sure you have the wit-bindgen program installed. 
Currently, SingleStoreDB only supports code generated using 
(wit-bindgen v0.2.0)[https://github.com/bytecodealliance/wit-bindgen/releases/tag/v0.2.0].

To compile:
```
make release
```

### Cleaning

To remove just the Wasm file:
```
make clean
```

To remove all generated files:
```
make distclean
```

