#!/usr/bin/env bash

#
# Implement the calculateLeadership.sh script on the block-producing node in your stake pool
# configuration.
#
# The script queries EKG metrics to retrieve the current epoch number and slot in epoch. If
# the current slot in epoch is later than the slot in epoch when the slot leadership schedule
# is available and the slot leadership query for the next epoch did not run already, then
# query the slot leadership schedule for the stake pool in the next epoch, saving the query
# results in JSON format using a unique file name.
#
# To use the script, set the following variables as needed to support your implementation:
#
#   - environment_option: Set the variable to match the environment that you use.
#   - epoch_duration: Set the epoch duration in seconds, less slightly more than the duration
#     that the slot leadership query requires to run.
#   - schedule_available: Set the slot in epoch when the leadership schedule is available
#     in the environment that you use.
#   - ekg_endpoint: If you change the IP address or port where the EKG endpoint listens, then
#     update the URL accordingly.
#   - node_home_folder: Set <NodeHomeValue> to the value of the $NODE_HOME environment variable
#     on the local computer.
#   - schedule_folder: Set the absolute path to the folder where the calculateLeadership.sh
#     script saves slot leadership query results informing the operator when the stake pool
#     is scheduled to produce blocks. To display statistics related to slot leadership, the
#     nodeView.sh script that you created in the Monitoring Metrics topic available online at
#     https://coincashew.io/spo/MonitoringMetrics must access the same folder.
#

#
# In the Mainnet and Pre-production environments, epoch duration is 5 days (432,000 seconds).
# The slot leadership schedule is available 1.5 days (129,600 seconds) prior to the next epoch
# starting. Therefore, the slot leadership schedule is available when the slot in epoch is
# greater than 302,400. As a margin of error, wait about 2 additional hours.
#
environment_option="--mainnet"
#environment_option="--testnet-magic 1"
epoch_duration="430000"
schedule_available="310000"

#
# In the Preview environment, epoch duration is 1 day (86,400 seconds). The slot leadership
# schedule is available 7.2 hours (25,920 seconds) prior to the next epoch starting. Therefore,
# the slot leadership schedule is available when the slot in epoch is greater than 60,480.
# As a margin of error, wait about 1 additional hour.
#
#environment_option="--testnet-magic 2"
#epoch_duration="85000"
#schedule_available="64000"

# Set the URL for the EKG endpoint
ekg_endpoint="http://localhost:12788/"

# The calculateLeadership.sh script may run as a systemd service. Therefore, assign the value
# of $NODE_HOME to a variable for use throughout the script because environment variables may
# not be available.
node_home_folder="<NodeHomeValue>"

# Assign the path to the folder for saving results of slot leadership queries to a variable
schedule_folder="${node_home_folder}/schedule"

# If schedule_folder does not exist, then create the directory
if [ ! -d "${schedule_folder}" ]
then

  mkdir -p ${schedule_folder}

fi

#
# The query_ekg_metrics function requests current EKG metrics from the specified Cardano Node
# endpoint. If the request fails, then the function retries in 30 seconds.
#
query_ekg_metrics() {

  # Query current EKG metrics
  until ekg_metrics=$(curl -s -H 'Accept: application/json' "${ekg_endpoint}")
  do

    # If the curl command failed, then inform the user
    echo "Failed to retrieve metrics, retrying in 30 seconds..."

    # Wait 30 seconds
    sleep 30

  done

}

#
# The assign_ekg_metrics function queries current EKG metrics. If metrics that the script
# requires are unavailable, then the function returns a non-zero exit status.
#
assign_ekg_metrics() {

  # Retrieve required metrics from current EKG metrics, assigning -1 as the default value
  dashboard_metrics=$(jq -r '
    .cardano.node.metrics.epoch.int.val // -1,
    .cardano.node.metrics.slotInEpoch.int.val // -1' <<< "${ekg_metrics}")

  # Assign retrieved metrics to an array
  dashboard_metrics_arr=($(echo "${dashboard_metrics}"))

  # Assign array entries to variables
  current_epoch_num=${dashboard_metrics_arr[0]}
  slot_in_epoch=${dashboard_metrics_arr[1]}

  # If any required metrics are unavailable, then return a non-zero exit code
  if (( current_epoch_num == -1 || slot_in_epoch == -1 ))
  then
    return 1
  fi

}

# Create a limitless loop
while true
do

  # Retrieve current EKG metrics
  query_ekg_metrics

  # Assign current EKG metrics to variables
  until assign_ekg_metrics
  do

    # If required EKG metrics are unavailable, then inform the user
    echo "Required metrics are unavailable, retrying in 30 seconds..."

    # Wait 30 seconds
    sleep 30

    # Refresh EKG metrics
    query_ekg_metrics

  done

  # Calculate the number of the next epoch
  next_epoch_num=$(( current_epoch_num + 1 ))

  # Assign the unique file name for saving the stake pool slot leadership schedule in the next epoch
  # to a variable
  schedule_filename="leadership-epoch${next_epoch_num}.json"

  # Set a default value for the variable used to calculate how long to wait prior to querying the
  # leadership schedule, if needed
  wait_time="${epoch_duration}"

  # If the file containing the slot leadership schedule for the stake pool in the next epoch does not exist
  if [ ! -f "${schedule_folder}/${schedule_filename}" ]
  then

    # If the slot leadership schedule for the next epoch is available
    if (( slot_in_epoch > schedule_available ))
    then

      # Inform the user
      echo "Calculating slot leadership for the next epoch, number ${next_epoch_num}..."

      # Query the leadership schedule for the next epoch, saving the results in a file
      /usr/local/bin/cardano-cli conway query leadership-schedule --output-json \
        --socket-path ${node_home_folder}/db/socket \
        --cardano-mode \
        ${environment_option} \
        --genesis ${node_home_folder}/shelley-genesis.json \
        --stake-pool-id $(cat ${node_home_folder}/stakepoolid-bech32.txt) \
        --vrf-signing-key-file ${node_home_folder}/vrf.skey \
        --next \
        --out-file ${schedule_folder}/${schedule_filename}

    else

      # Update how many seconds to wait before the next slot leadership schedule is available
      wait_time=$(( schedule_available - slot_in_epoch ))

    fi

  fi

  # Inform the user
  echo "Waiting ${wait_time} seconds until the next slot leadership schedule is available..."

  # Wait until the next slot leadership schedule is available
  sleep ${wait_time}

done