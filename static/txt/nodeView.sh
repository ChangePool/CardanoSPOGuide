#!/usr/bin/env bash

#
# The nodeView.sh script polls Cardano Node metrics every five seconds, and then displays a dashboard
# for the user.
#
# To use the script, set the following variables as needed to support your implementation:
#
#   - ekg_endpoint: If you change the IP address or port where the EKG endpoint listens, then
#     update the URL accordingly.
#   - environment_option: Set the variable to match the environment that you use.
#   - op_cert_path (Optional): Set the path to the current operational certificate for the stake pool.
#     For more details, see the Configuring the Block Producer and Issuing a New Operational Certificate
#     topics available online at https://coincashew.io/spo/ConfiguringBlockProducer and
#     https://coincashew.io/spo/IssuingOpCert respectively.
#   - schedule_folder (Optional): When monitoring relay nodes, the schedule_folder variable is unused.
#     When monitoring the block-producing node in your stake pool configuration, optionally set the
#     path to the folder where the calculateLeadership.sh script saves slot leadership query results
#     informing the operator when the stake pool is scheduled to produce blocks. For more details, see
#     Calculating Slot Leadership available online at https://coincashew.io/spo/CalculatingSlotLeadership
#
# To exit the script, press CTRL+C
#

# Set the URL for the EKG endpoint
ekg_endpoint="http://localhost:12788/"

# Uncomment a line to match the environment that you use
environment_option="--mainnet" # Mainnet environment
#environment_option="--testnet-magic 1" # Pre-production environment
#environment_option="--testnet-magic 2" # Preview environment

# Set the path to the current operational certificate for the stake pool
op_cert_path="$NODE_HOME/node.cert"

# When monitoring the block-producing node in your stake pool configuration, optionally set the path to the
# folder where the calculateLeadership.sh script saves slot leadership query results for the stake pool
schedule_folder="$NODE_HOME/schedule"

# Set locale for comma separation (e.g., US English)
#export LC_NUMERIC="en_US.UTF-8"

# The cleanup function runs on script exit
cleanup() {

  # Restore the cursor
  tput cnorm

}

# Register the cleanup function to run on script exit (including CTRL+C)
trap cleanup EXIT

# Hide the cursor
tput civis

# The convertsecs2hms function converts seconds to hh:mm:ss format
convertsecs2hms() {

  local total_seconds=$1
  local hours=$((total_seconds / 3600))
  local minutes=$(((total_seconds % 3600) / 60))
  local seconds=$((total_seconds % 60))

  printf "%02d:%02d:%02d\n" "$hours" "$minutes" "$seconds"

}

#
# The query_kes_info function parses optional data about the current KES period and operational certificate.
#
query_kes_period_info () {

  local kes_info=""
  local op_cert_error=""
  local current_kes_period=""
  local end_kes_period=""

  # Retrieve details about the current KES period and operational certificate
  kes_info=$(cardano-cli conway query kes-period-info ${environment_option} --op-cert-file ${op_cert_path} 2>&1)

  # Detect errors in the current KES period and operational certificate details
  op_cert_error=$(grep -e '✗' -e '<socket: 11>' <<< "${kes_info}")

  # If the details about the current KES period and operational certificate are error free
  if [[ -z "${op_cert_error}" ]]
  then
  
    # To preserve JSON formatting, drop the first two lines that the query kes-period-info command returns
    kes_info=$(tail -n +3 <<< "${kes_info}")
    
    # Retrieve values that the query kes-period-info command returns
    current_kes_period=$(jq -r '.qKesCurrentKesPeriod' <<< "${kes_info}")
    end_kes_period=$(jq -r '.qKesEndKesInterval' <<< "${kes_info}")
    expiry_date=$(jq -r '.qKesKesKeyExpiry' <<< "${kes_info}")

    # Calculate the number of KES periods remaining
    kes_periods_remaining=$(( end_kes_period - current_kes_period  ))

    # To create fixed widths, add trailing spaces to values as needed
    kes_periods_remaining=$(printf "%-2s" "${kes_periods_remaining}")

    # Format the date when the operational certificate expires
    expiry_date=$(date +"%Y-%m-%d" -d ${expiry_date})

   else

    # Inform the user that details about the current KES period and operational certificate contain errors
    kes_periods_remaining="Error"
    expiry_date="Error"

  fi

}

#
# When monitoring a block-producing node, the analyze_leadership function parses optional slot leadership
# data for the current and next epochs if available, and then updates variables used to display related
# statistics in the dashboard.
#
# NOTE: The analyze_leadership function seeks input data that the calculateLeadership.sh script outputs.
#
analyze_leadership() {

  # Initialize empty arrays for jq
  local current_epoch_leadership_json="[]"
  local next_epoch_leadership_json="[]"

  # If slot leadership data for the current epoch are available, then assign the data to a variable
  if [ -f "${current_epoch_leadership_file}" ]
  then

    current_epoch_leadership_json=$(jq -c . < ${current_epoch_leadership_file} )

  fi

  # If slot leadership data for the next epoch are available, then assign the data to a variable
  if [ -f "${next_epoch_leadership_file}" ]
  then

    next_epoch_leadership_json=$(jq -c . < ${next_epoch_leadership_file})

  fi

  # Concatenate available slot leadership data for the current and next epochs into a single JSON array
  local leadership_data=$(jq -n --argjson current_epoch "${current_epoch_leadership_json}" --argjson next_epoch "${next_epoch_leadership_json}" '$current_epoch + $next_epoch')

  # Sort available leadership data in ascending order by slot number
  leadership_data=$(echo "${leadership_data}" | jq 'sort_by(.slotNumber)')

  # To prepare statistics, iterate through the JSON array containing available slot leadership data
  while read -r object
  do

    # Assign values in the current JSON object to variables
    object_slot_num=$(jq -r '.slotNumber' <<< "${object}")
    object_slot_time=$(jq -r '.slotTime' <<< "${object}")

    # If the current object represents a slot occurring in the future
    if (( object_slot_num > slot_num ))
    then

      # Increment the variable counting the number of blocks a stake pool currently is scheduled to produce
      ((pending_blocks++))

      # If the variable storing the slot number of the next scheduled block is empty
      if [[ -z "${next_block_slot_num}" ]]
      then

        # Save values from the current JSON object as the next scheduled block
        next_block_slot_num=${object_slot_num}
        next_block_slot_time=${object_slot_time}

      fi

    fi

  done <<< $(jq -c '.[]' <<< "${leadership_data}")

  # If the stake pool is scheduled to produce one or more blocks
  if (( pending_blocks > 0 ))
  then

    # Format and convert to local time when the stake pool is scheduled to produce the next block
    next_block_slot_time=$(date +"%Y-%m-%d %H:%M:%S" -d ${next_block_slot_time})

    # Calculate the time remaining until the next block in seconds
    next_block_time_left=$(( next_block_slot_num - slot_num ))

    # Convert the time remaining until the next block from seconds to hh:mm:ss format
    next_block_time_left=$(convertsecs2hms ${next_block_time_left})

    # To create fixed widths, add trailing spaces to values as needed
    pending_blocks=$(printf "%-2s" "${pending_blocks}")

  fi

}

# Loop until the user presses CTRL+C
while true
do

  # Retrieve current metric values for the Cardano Node instance using the EKG endpoint
  ekg_metrics=$(curl -s -H 'Accept: application/json' "${ekg_endpoint}")

  # From the EKG metrics, retrieve metrics that the dashboard displays, setting alternatives for NULL values
  dashboard_metrics=$(jq -r '
    .cardano.node.metrics.epoch.int.val // 0,
    .cardano.node.metrics.slotInEpoch.int.val // 0,
    .cardano.node.metrics.slotNum.int.val // 0,
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
    .cardano.node.metrics.Forge["didnt-adopt"].int.val // 0,
    .cardano.node.metrics.slotsMissedNum.int.val // 0' <<< "${ekg_metrics}")

  # Assign the list of metrics that the dashboard displays to an array
  dashboard_metrics_arr=($(echo "${dashboard_metrics}"))

  # Assign array entries to variables
  current_epoch_num=${dashboard_metrics_arr[0]}
  slot_in_epoch=${dashboard_metrics_arr[1]}
  slot_num=${dashboard_metrics_arr[2]}
  block_height=${dashboard_metrics_arr[3]}
  incoming_conns=${dashboard_metrics_arr[4]}
  outgoing_conns=${dashboard_metrics_arr[5]}
  block_count=${dashboard_metrics_arr[6]}
  block_delay_1s=${dashboard_metrics_arr[7]}
  block_delay_3s=${dashboard_metrics_arr[8]}
  block_delay_5s=${dashboard_metrics_arr[9]}
  mem_heap=${dashboard_metrics_arr[10]}
  mem_live=${dashboard_metrics_arr[11]}
  block_producer=${dashboard_metrics_arr[12]}
  blocks_produced=${dashboard_metrics_arr[13]}
  blocks_adopted=${dashboard_metrics_arr[14]}
  blocks_invalid=${dashboard_metrics_arr[15]}
  slots_missed=${dashboard_metrics_arr[16]}

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

  # Calculate the number of the next epoch
  next_epoch_num=$(( current_epoch_num + 1 ))

  # Prior to formatting numbers, assign the expected names of files containing slot leadership data to variables
  current_epoch_leadership_file="${schedule_folder}/leadership-epoch${current_epoch_num}.json"
  next_epoch_leadership_file="${schedule_folder}/leadership-epoch${next_epoch_num}.json"

  # Format numbers using the thousands separator for the current system locale
  current_epoch_num=$(printf "%'d" "${current_epoch_num}")
  slot_in_epoch=$(printf "%'d" "${slot_in_epoch}")
  slot_num_formatted=$(printf "%'d" "${slot_num}")
  block_height=$(printf "%'d" "${block_height}")
  block_count=$(printf "%'d" "${block_count}")

  # To create fixed widths, add trailing spaces to values as needed
  current_epoch_num=$(printf "%-5s" "${current_epoch_num}")
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
  slots_missed=$(printf "%-2s" "${slots_missed}")

  # To create fixed widths, add leading spaces to values as needed
  block_delay_1s=$(printf "%*s%s" $((5 - ${#block_delay_1s})) "" "${block_delay_1s}")
  block_delay_3s=$(printf "%*s%s" $((5 - ${#block_delay_3s})) "" "${block_delay_3s}")
  block_delay_5s=$(printf "%*s%s" $((5 - ${#block_delay_5s})) "" "${block_delay_5s}")

  # Initialize variables used to display operational certificate statistics, if available
  kes_periods_remaining=""
  expiry_date=""

  # If an operational certificate is available
  if [ -f "${op_cert_path}" ]
  then

    # Call a function to query KES period information based on the operational certificate
    query_kes_period_info

  fi

  # Initialize variables used to display slot leadership statistics, if available
  pending_blocks=0
  next_block_slot_num=""
  next_block_slot_time=""
  next_block_time_left=""

  # Call a function to analyze optional slot leadership data
  analyze_leadership

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

  echo -e "                   ${Black}${WhiteBackground} nodeView v1.0 ${NoColor}"
  echo
  echo -e "${LightGreen}${Underline}Blockchain Ledger${NoColor}"
  echo -e "  Epoch Number: ${LightCyan}${current_epoch_num}${NoColor}         Slot in Epoch: ${LightCyan}${slot_in_epoch}${NoColor}"
  echo -e "  Block Height: ${LightCyan}${block_height}${NoColor}    Slot: ${LightCyan}${slot_num_formatted}${NoColor}"

  echo
  echo -e "${LightGreen}${Underline}Network Connections${NoColor}"
  echo -e "  Incoming: ${LightCyan}${incoming_conns}${NoColor}               Outgoing: ${LightCyan}${outgoing_conns}${NoColor}"

  echo
  echo -e "${LightGreen}${Underline}Block Propagation${NoColor}"
  echo -e "  Count    Within:    1 Second   3 Seconds   5 Seconds"
  echo -e "  ${LightCyan}${block_count}${NoColor}               ${LightCyan}${block_delay_1s}%${NoColor}     ${LightCyan}${block_delay_3s}%${NoColor}      ${LightCyan}${block_delay_5s}%${NoColor}"

  # When monitoring a block-producing node, display related metrics
  if [ ${block_producer} -eq 1 ]
  then

    # If operational certificate data are available, then display related statistics
    if [[ -n "${expiry_date}" ]]
    then

      echo
      echo -e "${LightGreen}${Underline}Operational Certificate${NoColor}"
      echo -e "  KES Periods Remaining: ${LightCyan}${kes_periods_remaining}${NoColor}   Expiry Date: ${LightCyan}${expiry_date}${NoColor}"

    fi

    echo
    echo -e "${LightGreen}${Underline}Block Production${NoColor}"

    # If slot leadership data are available for the stake pool, then display related statistics
    if (( pending_blocks > 0 ))
    then

      echo -e "  Pending               Next               Count Down"
      echo -e "     ${LightCyan}${pending_blocks}${NoColor}          ${LightCyan}${next_block_slot_time}${NoColor}        ${LightCyan}${next_block_time_left}${NoColor}"
      echo

    fi

    echo -e "  Prepared      Accepted      Invalid     Missed Slots"
    echo -e "     ${LightCyan}${blocks_produced}${NoColor}            ${LightCyan}${blocks_adopted}${NoColor}            ${LightCyan}${blocks_invalid}${NoColor}            ${LightCyan}${slots_missed}${NoColor}"

  fi

  echo
  echo -e "${LightGreen}${Underline}Memory Usage${NoColor}"
  echo -e "  Heap: ${LightCyan}${mem_heap}${NoColor}               Live: ${LightCyan}${mem_live}${NoColor}"

  echo
  echo -e "                    Quit: CTRL+C"

  # Wait five seconds prior to refreshing the dashboard
  sleep 5s

done
