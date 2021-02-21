#!/bin/sh

cat <<EOF >> $HOME/.cargo/config
[target.${TARGET_NAME}]
linker = "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ld"
ar = "${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar"

[build]
target = "${TARGET_NAME}"
rustflags = ["-C", "link-arg=-s"]
EOF
