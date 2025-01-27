#!/usr/bin/env bash
set -euo pipefail

TARGET="wasm32-unknown-unknown"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

pushd $SCRIPT_DIR/..

# NOTE: On macOS a specific version of llvm-ar and clang need to be set here.
# Otherwise the wasm compilation of rust-secp256k1 will fail.
if [ "$(uname)" == "Darwin" ]; then
  # On macs we need to use the brew versions
  AR="/usr/local/opt/llvm/bin/llvm-ar" CC="/usr/local/opt/llvm/bin/clang" cargo build --bin canister --target $TARGET --release
else
  cargo build --bin canister --target $TARGET --release
fi

set +e
# On macs m1 ignore error. ic-cdk-optimizer is required in production
cargo install --force --locked ic-cdk-optimizer --version 0.3.1 --root ./target
STATUS=$?

if [ "$STATUS" -eq "0" ]; then
      ./target/bin/ic-cdk-optimizer \
      ./target/$TARGET/release/canister.wasm \
      -o ./target/$TARGET/release/canister.wasm
  true
else
  echo Could not install ic-cdk-optimizer.
  false
fi
set -e

popd

