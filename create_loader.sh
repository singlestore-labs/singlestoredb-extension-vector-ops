#!/bin/bash

EXTENSION_NAME=$( find . -iname "*.wit" -exec basename {} .wit ';')
WASM_B64=$(cat ${EXTENSION_NAME}.wasm | base64 -w 0)
WIT_B64=$(cat ${EXTENSION_NAME}.wit | base64 -w 0)

cat <<EOF > load_extension.sql
CREATE OR REPLACE FUNCTION vector_pow_f64_helper AS WASM
FROM BASE64 '$WASM_B64'
WITH WIT FROM BASE64 '$WIT_B64'
USING EXPORT 'vector-pow-f64';

DELIMITER //
CREATE OR REPLACE FUNCTION vector_pow_f64(x LONGBLOB NULL, n DOUBLE NULL)
RETURNS LONGBLOB NULL AS
BEGIN
    IF x IS NULL OR n IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN vector_pow_f64_helper(x, n);
END //
DELIMITER ;
EOF

