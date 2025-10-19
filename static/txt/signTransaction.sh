cd $NODE_HOME
cardano-cli conway transaction sign \
  --tx-body-file tx.raw \
  {{signing-key-files}}--mainnet \
  --out-file tx.signed