all: build-server build-lb run

load-balancer-files = ../../LoadBalancer.cpp ../../LoadBalancer.hpp ../../../lib/httplib.h ../../../lib/json.hpp ../../../lib/umbridge.h

build-server:
	g++ -O3 -w -std=c++11 minimal-server.cpp -o server -lssl -lcrypto -pthread

build-lb:
	g++ -O3 -Wno-unused-result -std=c++17 $(load-balancer-files) -o ../../load-balancer -pthread

run:
	rm -f retry-job_id.txt
	mkdir -p logs
	rm -f logs/*

	export HQ_SUBMIT_DELAY_MS=500
	$$PORT ?= 4242

	while nc -z localhost $$PORT; do \
		read -p "Port $$PORT is already in use. Please enter a different port: " NEW_PORT; \
		PORT=$${NEW_PORT:-$$PORT}; \
	done; \
	cd ../../ && ./load-balancer