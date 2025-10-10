#!/bin/bash

#
# Keys used in Cardano transactions are five derivations away from the seed phrase,
# using the derivation path 1852H/1815H/<x>H/<y>/<z> where:
#
#   - 1852 is the coin ID for ADA
#   - 1815 is an extra, unused path
#   - <x> is the wallet index number
#   - <y> is 0 or 1 indicating the payment key path for wallet <x>, or 2 indicating the
#     staking key path
#   - <z> is the key number
#
# To run the createWallet.sh script, type the following command where <Index> is 0 or 1
# indicating the payment key path for the wallet, <OutputFolder> is the location where
# you want the script to save keys and addresses, and <SeedPhrase> is the 24-word seed
# phrase that you want the script to use:
#
# createWallet.sh <Index> <OutputFolder> <SeedPhrase>
#

#
# Assign paths to required binaries and files to variables
#
CADDR=${CADDR:=$(which cardano-address)}
[[ -z "$CADDR" ]] && { echo "cardano-address is not available. Exiting..." >&2 ; exit 1; }

CCLI=${CCLI:=$(which cardano-cli)}
[[ -z "$CCLI" ]] && { echo "cardano-cli is not available. Exiting..." >&2 ; exit 1; }

BECH32=${BECH32:=$(which bech32)}
[[ -z "$BECH32" ]] && { echo "bech32 is not available. Exiting..." >&2 ; exit 1; }

GEN_FILE=${GEN_FILE:="./shelley-genesis.json"}
[[ ! -f "$GEN_FILE" ]] && { echo "Shelley genesis file is not available. Exiting..." >&2 ; exit 1; }

#
# Only support 24-word seed phrases
#
[[ "$#" -ne 26 ]] && {
  echo "usage: $(basename $0) Arguments passed to the script are incorrect. Only 24-word seed phrases are supported." >&2
  exit 1
}

IDX=$1
shift

OUT_DIR="$1"
[[ -e "$OUT_DIR"  ]] && {
  echo "The folder $OUT_DIR already exists. Please delete the folder, and then run the createWallet.sh script again." >&2
  exit 1
} || mkdir -p "$OUT_DIR" && pushd "$OUT_DIR" >/dev/null

shift
SEEDPHRASE="$*"

# Using the seed phrase, generate the master key
echo "$SEEDPHRASE" | "$CADDR" key from-recovery-phrase Shelley > root.prv

# Using the master key, generate the extended private stake address key
cat root.prv | "$CADDR" key child 1852H/1815H/0H/2/0 > stake.xprv

# Using the master key, generate the extended private payment address key
cat root.prv | "$CADDR" key child 1852H/1815H/0H/$IDX/0 > payment.xprv

NW=$(jq '.networkId' -r "$GEN_FILE")
NW_ID=$(jq '.networkMagic' -r "$GEN_FILE")

echo "Generating $NW wallet..."
if [ "$NW" == "Testnet" ]; then
  NETWORK=0
  MAGIC="--testnet-magic $NW_ID"
else
  NETWORK=1
  MAGIC="--mainnet"
fi

# Using the extended private keys, generate the extended public keys
cat payment.xprv |\
  "$CADDR" key public --with-chain-code | tee payment.xpub |\
  "$CADDR" address payment --network-tag $NETWORK |\
  "$CADDR" address delegation $(cat stake.xprv | "$CADDR" key public --with-chain-code | tee stake.xpub) |\
  tee payment.addr_candidate |\
  "$CADDR" address inspect

echo

echo "Generated using derivation path 1852H/1815H/0H/$IDX/0"

if [ "$NW" == "Testnet" ]; then
  cat payment.addr_candidate | bech32 | bech32 addr_test > payment.addr_candidate_test
  mv payment.addr_candidate_test payment.addr_candidate
fi

cat payment.addr_candidate
echo

# Using extended private keys, generate Shelley-format secret signing keys
"$CCLI" conway key convert-cardano-address-key --shelley-payment-key --signing-key-file payment.xprv --out-file payment.skey
"$CCLI" conway key convert-cardano-address-key --shelley-stake-key --signing-key-file stake.xprv --out-file stake.skey

# Using Shelley-format secret signing keys, generate extended public verification keys
"$CCLI" conway key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey
"$CCLI" conway key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey

# Using extended public verification keys, generate Shelley-format public verification keys
"$CCLI" conway key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey
"$CCLI" conway key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey

# Using the stake address public verification key, generate the stake address
"$CCLI" conway stake-address build --stake-verification-key-file stake.vkey $MAGIC --out-file stake.addr

# Using the payment address public verification key, generate the payment address NOT associated
# with the stake address
"$CCLI" conway address build --payment-verification-key-file payment.vkey $MAGIC --out-file enterprise.addr

# Using the payment address and stake address public verification keys, generate the payment address
# associated with the stake address
"$CCLI" conway address build \
  --payment-verification-key-file payment.vkey \
  --stake-verification-key-file stake.vkey \
  $MAGIC \
  --out-file payment.addr

echo "Verify that the payment address Cardano CLI generates matches the payment address Cardano Wallet generates:"
diff -s payment.addr payment.addr_candidate

echo
cat payment.addr
echo
cat payment.addr_candidate

popd