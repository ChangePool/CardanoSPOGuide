fee=$(cardano-cli conway transaction calculate-min-fee --output-json \
  --tx-body-file tx.tmp \
  --tx-in-count ${txcnt} \
  --tx-out-count {{tx-out-count}} \
  --witness-count {{witness-count}} \
  --byron-witness-count 0 \
  --protocol-params-file $NODE_HOME/params.json | jq -r '.fee')
echo fee: ${fee}