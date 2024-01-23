all: build-server build-lb run-lb

load-balancer-files = ../../LoadBalancer.cpp ../../LoadBalancer.hpp ../../lib/httplib.h ../../lib/json.hpp ../../lib/umbridge.h

build-server:
	chmod +x hq_scripts/*
	g++ -O3 -w -std=c++11 minimal-server.cpp -o server -lssl -lcrypto -pthread

build-lb:
	g++ -O3 -Wno-unused-result -std=c++17 $(load-balancer-files) -o load-balancer -pthread

run-lb:
	./load-balancer