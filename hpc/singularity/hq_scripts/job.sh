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

echo "Building singularity sandbox at $TMPDIR/$HQ_JOB_ID/ ."
# make a copy of sandbox to avoid overwriting
# $TMPDIR is the temporary directory at each node on Helix
mkdir -p $TMPDIR/$HQ_JOB_ID/
cp -r l2-sea.simg $TMPDIR/$HQ_JOB_ID/
# need to pull the image from singularity hub first
# singularity build --sandbox $TMPDIR/$HQ_JOB_ID/l2-sea.simg l2-sea.sif
# singularity pull $TMPDIR/$HQ_JOB_ID/l2-sea.sif library://lennoxl/umbridge/l2-sea:latest
# convert image from read-only to modifiable
# singularity build --sandbox $TMPDIR/$HQ_JOB_ID/l2-sea.simg $TMPDIR/$HQ_JOB_ID/l2-sea.sif

echo "Finish building singularity sandbox at $TMPDIR/$HQ_JOB_ID/ ."

echo "Starting singularity server at http://$host:$port"
# load umbridge server from local file
singularity run --writable --bind ./load-balancer_singularity/umbridge-server:/umbridge-server --bind ./output:/output --pwd /umbridge-server $TMPDIR/$HQ_JOB_ID/l2-sea.simg $port &

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