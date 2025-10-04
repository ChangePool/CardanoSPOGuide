#!/bin/bash

#
# The following script polls metrics for the local Cardano Node instance
# every five seconds, and then displays a dashboard for the user.
#
# To exit the script, press CTRL+C
#

# The cleanup function runs on script exit
cleanup() {
  # Restore the cursor
  tput cnorm
}

# Register the cleanup function to run on script exit (including CTRL+C)
trap cleanup EXIT

# Hide the cursor
tput civis

# Set locale for comma separation (e.g., US English)
#export LC_NUMERIC="en_US.UTF-8"

# Loop until the user presses CTRL+C
while true
do

  # Retrieve current metric values for the Cardano Node instance using the EKG endpoint
  # NOTE: If you changed the IP address or port where the EKG endpoint listens, then update the URL accordingly
  ekg_metrics=$(curl -s -H 'Accept: application/json' http://localhost:12788/)

  # From the EKG metrics, retrieve metrics that the dashboard displays, setting alternatives for NULL values
  dashboard_metrics=$(jq -r '
    .cardano.node.metrics.epoch.int.val // 0,
    .cardano.node.metrics.slotInEpoch.int.val // 0,
    .cardano.node.metrics.blockNum.int.val // 0,
    .cardano.node.metrics.connectionManager.incomingConns.val // 0,
    .cardano.node.metrics.connectionManager.outgoingConns.val // 0,
    .cardano.node.metrics.served.block.count.int.val // 0,
    .cardano.node.metrics.blockfetchclient.blockdelay.cdfOne.val // 0,
    .cardano.node.metrics.blockfetchclient.blockdelay.cdfThree.val // 0,
    .cardano.node.metrics.blockfetchclient.blockdelay.cdfFive.val // 0,
    .cardano.node.metrics.RTS.gcHeapBytes.int.val // 0,
    .cardano.node.metrics.RTS.gcLiveBytes.int.val // 0,
    .cardano.node.metrics.forging_enabled.val // 0,
    .cardano.node.metrics.Forge["node-is-leader"].int.val // 0,
    .cardano.node.metrics.Forge.adopted.int.val // 0,
    .cardano.node.metrics.Forge["didnt-adopt"].int.val // 0' <<< "${ekg_metrics}")

  # Assign the list of metrics that the dashboard displays to an array
  dashboard_metrics_arr=($(echo "${dashboard_metrics}"))

  # Assign array entries to variables
  epoch_num=${dashboard_metrics_arr[0]}
  slot_in_epoch=${dashboard_metrics_arr[1]}
  block_height=${dashboard_metrics_arr[2]}
  incoming_conns=${dashboard_metrics_arr[3]}
  outgoing_conns=${dashboard_metrics_arr[4]}
  block_count=${dashboard_metrics_arr[5]}
  block_delay_1s=${dashboard_metrics_arr[6]}
  block_delay_3s=${dashboard_metrics_arr[7]}
  block_delay_5s=${dashboard_metrics_arr[8]}
  mem_heap=${dashboard_metrics_arr[9]}
  mem_live=${dashboard_metrics_arr[10]}
  block_producer=${dashboard_metrics_arr[11]}
  blocks_produced=${dashboard_metrics_arr[12]}
  blocks_adopted=${dashboard_metrics_arr[13]}
  blocks_invalid=${dashboard_metrics_arr[14]}

  # Format and round percentages for display
  block_delay_1s=$(echo "scale=1; ((${block_delay_1s} * 1000) + 0.5) / 10" | bc)
  block_delay_3s=$(echo "scale=1; ((${block_delay_3s} * 1000) + 0.5) / 10" | bc)
  block_delay_5s=$(echo "scale=1; ((${block_delay_5s} * 1000) + 0.5) / 10" | bc)

  # Round bytes to GB for display
  mem_heap=$(echo "scale=1; ((${mem_heap} / 100000000) + 0.5) / 10" | bc)
  mem_live=$(echo "scale=1; ((${mem_live} / 100000000) + 0.5) / 10" | bc)

  # Append the unit
  mem_heap="${mem_heap} GB"
  mem_live="${mem_live} GB"

  # Format numbers using the thousands separator for the current system locale
  epoch_num=$(printf "%'d\n" "${epoch_num}")
  slot_in_epoch=$(printf "%'d\n" "${slot_in_epoch}")
  block_height=$(printf "%'d\n" "${block_height}")
  block_count=$(printf "%'d\n" "${block_count}")

  # To create fixed widths, add trailing spaces to values as needed
  epoch_num=$(printf "%-5s" "${epoch_num}")
  slot_in_epoch=$(printf "%-7s" "${slot_in_epoch}")
  block_height=$(printf "%-10s" "${block_height}")
  incoming_conns=$(printf "%-3s" "${incoming_conns}")
  outgoing_conns=$(printf "%-3s" "${outgoing_conns}")
  block_count=$(printf "%-5s" "${block_count}")
  mem_heap=$(printf "%-7s" "${mem_heap}")
  mem_live=$(printf "%-7s" "${mem_live}")
  blocks_produced=$(printf "%-2s" "${blocks_produced}")
  blocks_adopted=$(printf "%-2s" "${blocks_adopted}")
  blocks_invalid=$(printf "%-2s" "${blocks_invalid}")

  # To create fixed widths, add leading spaces to values as needed
  block_delay_1s=$(printf "%*s%s" $((5 - ${#block_delay_1s})) "" "${block_delay_1s}")
  block_delay_3s=$(printf "%*s%s" $((5 - ${#block_delay_3s})) "" "${block_delay_3s}")
  block_delay_5s=$(printf "%*s%s" $((5 - ${#block_delay_5s})) "" "${block_delay_5s}")

  # Define colors and styles
  Black="\e[30m"
  Green="\e[32m"
  Yellow="\e[33m"
  Red="\e[31m"
  Cyan="\e[36m"
  LightGreen="\e[92m"
  LightCyan="\e[96m"
  LightBlue="\e[94m"
  CyanBackground="\e[46m"
  LightCyanBackground="\e[106m"
  MagentaBackground="\e[45m"
  WhiteBackground="\e[107m"
  Bold="\e[1m"
  Underline="\e[4m"
  NoColor="\e[0m"

  #
  # Display the dashboard for the user
  #

  # Clear the screen
  clear

  echo -e "                   ${Black}${WhiteBackground} NodeView v1.0 ${NoColor}"
  echo
  echo -e "${LightGreen}${Underline}Blockchain Ledger${NoColor}"
  echo -e "  Epoch Number: ${LightCyan}${epoch_num}${NoColor}         Slot in Epoch: ${LightCyan}${slot_in_epoch}${NoColor}"
  echo -e "  Block Height: ${LightCyan}${block_height}${NoColor}"

  echo
  echo -e "${LightGreen}${Underline}Network Connections${NoColor}"
  echo -e "  Incoming: ${LightCyan}${incoming_conns}${NoColor}               Outgoing: ${LightCyan}${outgoing_conns}${NoColor}"

  echo
  echo -e "${LightGreen}${Underline}Block Propagation${NoColor}"
  echo -e "  Count    Within: 1 Second   3 Seconds   5 Seconds"
  echo -e "  ${LightCyan}${block_count}${NoColor}             ${LightCyan}${block_delay_1s}%${NoColor}     ${LightCyan}${block_delay_3s}%${NoColor}      ${LightCyan}${block_delay_5s}%${NoColor}"

  # If the node is a block producer, then display block production metrics
  if [ ${block_producer} -eq 1 ]
  then

    echo
    echo -e "${LightGreen}${Underline}Block Production${NoColor}"
    echo -e "  Prepared: ${LightCyan}${blocks_produced}${NoColor}      Accepted: ${LightCyan}${blocks_adopted}${NoColor}    Invalid: ${LightCyan}${blocks_invalid}${NoColor}"

  fi

  echo
  echo -e "${LightGreen}${Underline}Memory Usage${NoColor}"
  echo -e "  Heap: ${LightCyan}${mem_heap}${NoColor}               Live: ${LightCyan}${mem_live}${NoColor}"

  echo
  echo -e "                    Quit: CTRL+C"

  # Wait five seconds prior to refreshing the dashboard
  sleep 5s

done