#! /bin/bash

#HQ --cpus=1
#HQ --time-request=1m
#HQ --time-limit=2m
#HQ --stdout %{CWD}/test/MultiplyBy2/logs/job-%{JOB_ID}.out
#HQ --stderr %{CWD}/test/MultiplyBy2/logs/job-%{JOB_ID}.err

# Launch model server, send back server URL
# and wait to ensure that HQ won't schedule any more jobs to this allocation.


# Define the range of ports to select from
MIN_PORT=1024
MAX_PORT=65535
# Generate a random port number
port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)
# Check if the port is in use
try_count=0
while lsof -Pi :$port -sTCP:LISTEN -t
do
    echo "Port $port is in use, trying another port"
    # If the port is in use, generate a new port number
    port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)

    try_count=$((try_count+1))
done
echo "Selected port $port after $try_count tries"

echo "Starting server on port $port"
export PORT=$port
# Assume that server sets the port according to the environment variable 'PORT'.
./test/MultiplyBy2/server & # CHANGE ME!

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
