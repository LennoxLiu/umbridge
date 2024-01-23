all: pull-server pull-lb run-lb

# If port is not set, use the default value "4242"
port ?= 4242

build: build-server build-lb pull

pull: pull-server pull-lb

publish:
	# push image to remote library
	singularity push -U l2-sea.sif library://lennoxl/umbridge/l2-sea:latest
	singularity push -U load-balancer.sif library://lennoxl/umbridge/load-balancer:latest

build-server:
	# remove old image if it exists
	rm l2-sea.simg -rf
	rm l2-sea.sif

	# create read-only image from definition file
	singularity build --remote l2-sea.sif l2-sea.def

run-server:
	# create output folder if it doesn't exist
	mkdir -p ./load-balancer_singularity/output

	# load umbridge server from local file
	singularity run --writable --bind ./load-balancer_singularity/umbridge-server:/umbridge-server --bind ./load-balancer_singularity/output:/output --pwd /umbridge-server  l2-sea.simg $(port)

pull-server:
	#singularity pull l2-sea.sif library://lennoxl/umbridge/l2-sea:latest
	
	# convert image from read-only to modifiable
	singularity build --sandbox ./load-balancer_singularity/l2-sea.simg l2-sea.sif

load-balancer-files = ../LoadBalancer.cpp ../LoadBalancer.hpp ../lib/httplib.h ../lib/json.hpp ../lib/umbridge.h

build-lb-local:
	g++ -O3 -Wno-unused-result -std=c++17 $(load-balancer-files) -o load-balancer -pthread

run-lb-local:
	export PORT=$(port)
	./load-balancer

build-lb:
	# remove old image if it exists
	rm load-balancer.simg -rf
	rm load-balancer.sif

	# need sudo to build from definition file, so we have to add --remote flag to build from remote
	singularity build --remote load-balancer.sif load-balancer.def

pull-lb:
	#singularity pull load-balancer.sif library://lennoxl/umbridge/load-balancer:latest

	# convert read-only image to sandbox image
	singularity build --sandbox load-balancer.simg load-balancer.sif

run-lb:
	# add execute permission to all scripts in hq_scripts folder
	chmod +x ./load-balancer_singularity/hq_scripts/*

	# bind local hq config to sandbox (Secondly, bind the local folder to working folder in sandbox)
	singularity run --bind ./load-balancer_singularity:/load-balancer_singularity --writable --pwd /load-balancer_singularity load-balancer.simg $(port)