#! /bin/bash

#HQ --cpus=1
#HQ --time-request=1m
#HQ --time-limit=2m
#HQ --stdout %{CWD}/logs/job-%{JOB_ID}.out
#HQ --stderr %{CWD}/logs/job-%{JOB_ID}.err

# Launch model server, send back server URL
# and wait to ensure that HQ won't schedule any more jobs to this allocation.

function get_avaliable_port {
    # Define the range of ports to select from
    MIN_PORT=60000
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

# Assume that server sets the port according to the environment variable 'PORT'.
export PORT=$port && singularity run --writable-tmpfs model-l2-sea-singularity_latest.sif & # CHANGE ME!

load_balancer_dir="./" # CHANGE ME!


host=$(hostname -I | awk '{print $1}')

echo "Waiting for model server to respond at $host:$port..."
while ! curl -s "http://$host:$port/Info" > /dev/null; do
    sleep 1
done
echo "Model server responded"

# Write server URL to file identified by HQ job ID.
mkdir -p "$load_balancer_dir/urls"
echo "http://$host:$port" > "$load_balancer_dir/urls/url-$HQ_JOB_ID.txt"

sleep infinity # keep the job occupied
