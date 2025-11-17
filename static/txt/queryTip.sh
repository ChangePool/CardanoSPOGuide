currentSlot=$(cardano-cli conway query tip --mainnet | jq -r '.slot')
echo "Current Slot: ${currentSlot}"
