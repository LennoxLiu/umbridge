all:

load-balancer-files = LoadBalancer.cpp LoadBalancer.hpp ../lib/httplib.h ../lib/json.hpp ../lib/umbridge.h

build:
	g++ -O3 -Wno-unused-result -std=c++17 $(load-balancer-files) -o load-balancer -pthread

pull-l2sea:
	singularity pull docker://linusseelinger/model-l2-sea-singularity

run:
	mkdir -p logs
	rm -f logs/*
	if ! printenv PORT > /dev/null; then \
	echo "PORT environment variable not set. Using default value 4242."; \
	export PORT=4242; \
	fi && \
	export HQ_SUBMIT_DELAY_MS=100 && \
	while nc -z localhost $$PORT; do \
		read -p "Port $$PORT is already in use. Please enter a different port: " NEW_PORT; \
		PORT=$${NEW_PORT:-$$PORT}; \
	done; \
	./load-balancer
