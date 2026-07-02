#!/bin/bash
set -e  # Exit immediately if any command fails

# 1. Spawn Bitcoind
docker compose up -d
sleep 15 # Give it a bit more time to wake up

echo "Waiting for bitcoind to be fully initialized..."

while true; do
  result=$(curl --silent --user alice:password --data-binary \
    '{"jsonrpc":"1.0","id":"ping","method":"getblockchaininfo","params":[]}' \
    -H 'content-type: text/plain;' http://127.0.0.1:18443)

  if echo "$result" | grep -q '"chain"'; then
    echo "bitcoind is ready."
    break
  else
    echo "bitcoind not ready yet, retrying in 3s..."
    sleep 3
  fi
done

# 2. Run your Rust project
chmod +x ./rust/run-rust.sh
./rust/run-rust.sh

# 3. Clean up
docker compose down -v
