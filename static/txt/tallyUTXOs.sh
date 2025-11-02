# Retrieve the list of UTXOs available for your payment address
utxo_json=$(cardano-cli conway query utxo --output-json \
  --address $(cat $NODE_HOME/payment.addr) \
  --mainnet)

# Initialize variables
tx_in=""
total_balance=0

# Loop through the list of UTXOs
while read -r utxo; do
  # Retrieve the values for the current UTXO
  values=$(jq -r --arg k "${utxo}" '.[$k]' <<< "${utxo_json}")
  # Retrieve datum associated with the UTXO
  datum=$(jq -r '.datum' <<< "${values}")
  # Retrieve the reference script associated with the UTXO
  script=$(jq -r '.referenceScript' <<< "${values}")
  # If limits on spending the UTXO may exist, then skip the UTXO
  if [[ ${datum} == 'null' && ${script} == 'null' ]]
  then
    hash=${utxo%%#*}
    idx=${utxo#*#}
    utxo_balance=$(jq -r '.value.lovelace' <<< "${values}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo "TxHash: ${hash}#${idx}"
    echo "UTXO Balance: ${utxo_balance} Lovelace"
    tx_in="${tx_in} --tx-in ${hash}#${idx}"
  fi
done <<< "$(jq -r 'keys[]' <<< "${utxo_json}")"

echo
echo "Total available balance: ${total_balance} Lovelace"
echo "Final --tx-in string:${tx_in}"