#! /bin/bash

#HQ --resource model=1
#HQ --time-request=2m
#HQ --time-limit=10m

# Launch model server, send back server URL
# and wait to ensure that HQ won't schedule any more jobs to this allocation.

function get_avaliable_port {
    # Define the range of ports to select from
    MIN_PORT=1024
    MAX_PORT=65535

    # Generate a random port number
    port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)

    # Check if the port is in use
    while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; do
        # If the port is in use, generate a new random port number
        port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)
    done

    echo $port
}

port=$(get_avaliable_port)
export PORT=$port

host=$(hostname -I | awk '{print $1}')

# Assume that server sets the port according to the environment variable 'PORT'.
# Run server in background
# create output folder if it doesn't exist
mkdir -p ./output

echo "Creating folder for job at ./tmpdir/$HQ_JOB_ID/ ."
mkdir -p ./tmpdir/$HQ_JOB_ID/
rm -rf ./tmpdir/$HQ_JOB_ID/*
mkdir -p ./tmpdir/$HQ_JOB_ID/output
cp -r overlay.img ./tmpdir/$HQ_JOB_ID/

# echo "Finish building singularity sandbox at ./tmpdir/$HQ_JOB_ID/ ."

echo "Starting singularity server at http://$host:$port"
# load umbridge server from local file
singularity run --overlay ./tmpdir/$HQ_JOB_ID/overlay.img --bind ./load-balancer_singularity/umbridge-server:/umbridge-server --bind ./tmpdir/$HQ_JOB_ID/output:/output --pwd /umbridge-server model-l2-sea-singularity_latest.sif  $port &

load_balancer_dir="./"

# Wait for model server to start
while ! curl -s "http://$host:$port/Info" > /dev/null; do
    sleep 1
done

# Write server URL to file identified by HQ job ID.
mkdir -p "$load_balancer_dir/urls"
echo "http://$host:$port" > "$load_balancer_dir/urls/url-$HQ_JOB_ID.txt"

echo "Singularity server started at http://$host:$port"

sleep infinity # keep the job occupied