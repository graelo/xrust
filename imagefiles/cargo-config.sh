#!/bin/sh

cat <<EOF >> $HOME/.cargo/config
[build]
target = "${TARGET_NAME}"
rustflags = ["-C", "link-arg=-s"]

[target.${TARGET_NAME}]
linker = "${CROSS_TRIPLE}-ld"
ar = "${CROSS_TRIPLE}-ar"
EOF
