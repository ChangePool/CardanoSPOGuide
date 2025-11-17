fee=$(cardano-cli conway transaction calculate-min-fee --output-json \
  --tx-body-file $NODE_HOME/tx.tmp \
  --witness-count {{witness-count}} \
  --byron-witness-count 0 \
  --protocol-params-file $NODE_HOME/params.json | jq -r '.fee')
echo "Fee: ${fee}"