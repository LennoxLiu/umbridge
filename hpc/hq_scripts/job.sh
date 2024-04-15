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
echo "$(lsof -Pi :$port -sTCP:LISTEN -t )"
while [ -n  "$(lsof -Pi :$port -sTCP:LISTEN -t )" ] || [ $(nc -l $port  &>/dev/null  &) ]
do
    echo "Port $port is in use, trying another port"
    # If the port is in use, generate a new port number
    port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)

    # Hold the port
    # nc -l $port &

    try_count=$((try_count+1))
done
echo "Selected port $port after $try_count tries"

if [ $try_count -gt 0 ]; then
    echo "$HQ_JOB_ID" > "./test/MultiplyBy2/retry-job_id.txt"
fi

echo "Starting server on port $port"
export PORT=$port
# Assume that server sets the port according to the environment variable 'PORT'.
# Release the port before starting the server to avoid conflicts.

[ ! $(nc -l $port  &>/dev/null  &) ] && echo "Port $port is not killed"
fuser -k -n tcp $port && ./test/MultiplyBy2/server & # CHANGE ME!

load_balancer_dir="./" # CHANGE ME!

host=$(hostname -I | awk '{print $1}')

timeout=60 # timeout in seconds
echo "Waiting for model server to respond at $host:$port..."

function server_is_up() {
    while ! curl -s "http://$host:$port/Info" > /dev/null; do
        sleep 1
    done
}

if timeout $timeout server_is_up; then
    echo "Model server responded within $timeout seconds"
else
    echo "Timeout: Model server did not respond within $timeout seconds"
    exit 1
fi

# Write server URL to file identified by HQ job ID.
mkdir -p "$load_balancer_dir/urls"
echo "http://$host:$port" > "$load_balancer_dir/urls/url-$HQ_JOB_ID.txt"

sleep infinity # keep the job occupied
