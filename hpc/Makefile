all:

load-balancer-files = LoadBalancer.cpp LoadBalancer.hpp ../lib/httplib.h ../lib/json.hpp ../lib/umbridge.h

build:
	g++ -O3 -Wno-unused-result -std=c++17 $(load-balancer-files) -o load-balancer -pthread

pull-l2sea:
	singularity pull docker://linusseelinger/model-l2-sea-singularity

run:
	mkdir -p logs
	rm -f logs/*
	export HQ_SUBMIT_DELAY_MS=500 && \
	./load-balancer
