#!/bin/bash

#
# To run the createWallet.sh script, type the following command where <Index> is 0 or 1
# indicating the payment key path for the wallet, <OutputFolder> is the location where
# you want the script to save keys and addresses, and <SeedPhrase> is the 24-word seed
# phrase that you want the script to use:
#
# createWallet.sh <Index> <OutputFolder> <SeedPhrase>
#
# For example, type:
#
# ./createWallet.sh 0 wallet-keys $(cat seed-phrase.dat)
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
# NOTE: An extended key may derive a hierarchy of other keys. Normal keys represent a
# single, standalone key pair.
#
# NOTE: An enterprise address is a payment address that cannot participate in staking.
#
# For more details on Cardano Wallet, see https://cardano-foundation.github.io/cardano-wallet/
#
# For more details on using the cardano-address binary, to access built-in help type:
#
# cardano-address --help
#

#
# Assign paths to required binaries to variables
#
CADDR=${CADDR:=$(which cardano-address)}
[[ -z "$CADDR" ]] && { echo "cardano-address is not available. Exiting..." >&2 ; exit 1; }

CCLI=${CCLI:=$(which cardano-cli)}
[[ -z "$CCLI" ]] && { echo "cardano-cli is not available. Exiting..." >&2 ; exit 1; }

BECH32=${BECH32:=$(which bech32)}
[[ -z "$BECH32" ]] && { echo "bech32 is not available. Exiting..." >&2 ; exit 1; }

#
# Parse arguments passed to the script
#

# Only support 24-word seed phrases
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

#
# If the Shelley Genesis file exists, then query to retrieve required values
#
GEN_FILE=${GEN_FILE:="../shelley-genesis.json"}
[[ ! -f "$GEN_FILE" ]] && { echo "Shelley genesis file is not available. Exiting..." >&2 ; exit 1; }

NW_ID=$(jq '.networkMagic' -r "$GEN_FILE")

MAGIC="--testnet-magic $NW_ID"

case $NW_ID in
  1)
    NETWORK="preprod"
    ;;
  2)
    NETWORK="preview"
    ;;
  *)
    NETWORK="mainnet"
    MAGIC="--mainnet"
    ;;
esac

#
# Derive keys and addresses
#

echo
echo "Generating wallet in the $NETWORK environment..."
echo

# Convert the seed phrase into the master key
echo "$SEEDPHRASE" | "$CADDR" key from-recovery-phrase Shelley > root.prv

# Using the master key, derive the extended private stake address key
cat root.prv | "$CADDR" key child 1852H/1815H/0H/2/0 > stake.xprv

# Using the master key, derive the extended private payment address key
cat root.prv | "$CADDR" key child 1852H/1815H/0H/$IDX/0 > payment.xprv

# Using the extended private keys, derive the extended public keys
# as well as the enterprise address and payment address
cat payment.xprv \
  | "$CADDR" key public --with-chain-code \
  | tee payment.xpub \
  | "$CADDR" address payment --network-tag $NETWORK \
  | tee enterprise.addr_candidate \
  | "$CADDR" address delegation $(cat stake.xprv | "$CADDR" key public --with-chain-code | tee stake.xpub) \
  | tee payment.addr_candidate \
  | "$CADDR" address inspect

echo
echo "Wallet generated using derivation path 1852H/1815H/0H/$IDX/0"
echo

# Using Cardano CLI, convert extended private keys to the corresponding Shelley-format secret signing key
"$CCLI" conway key convert-cardano-address-key --shelley-payment-key --signing-key-file payment.xprv --out-file payment.skey
"$CCLI" conway key convert-cardano-address-key --shelley-stake-key --signing-key-file stake.xprv --out-file stake.skey

# Using secret signing keys, get extended public verification keys
"$CCLI" conway key verification-key --signing-key-file payment.skey --verification-key-file payment.evkey
"$CCLI" conway key verification-key --signing-key-file stake.skey --verification-key-file stake.evkey

# Using extended public verification keys, get normal public verification keys
"$CCLI" conway key non-extended-key --extended-verification-key-file payment.evkey --verification-key-file payment.vkey
"$CCLI" conway key non-extended-key --extended-verification-key-file stake.evkey --verification-key-file stake.vkey

# Using the stake address public verification key, generate the stake address
"$CCLI" conway stake-address build --stake-verification-key-file stake.vkey $MAGIC --out-file stake.addr

# Using the payment address public verification key, generate the enterprise address
"$CCLI" conway address build --payment-verification-key-file payment.vkey $MAGIC --out-file enterprise.addr

# Using the payment address and stake address public verification keys, generate the payment address
# associated with the stake address
"$CCLI" conway address build \
  --payment-verification-key-file payment.vkey \
  --stake-verification-key-file stake.vkey \
  $MAGIC \
  --out-file payment.addr

echo "WARNING:  If the address in the payment.addr file Cardano CLI generates does NOT match the address in the payment.addr_candidate file"
echo "          Cardano Wallet generates, then do NOT use the wallet:"
echo
echo "          payment.addr: $(cat payment.addr)"
echo "payment.addr_candidate: $(cat payment.addr_candidate)"
echo
diff -s payment.addr payment.addr_candidate
echo

popd > /dev/null