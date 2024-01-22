all: run-server

# If port is not set, use the default value "4242"
port ?= 4242

build-server:
	singularity build --remote --sandbox l2-sea.simg l2-sea.def

	# convert sandbox image to read-only image
	singularity build l2-sea.sif l2-sea.simg

	# publish image to singularity hub
	singularity push -U l2-sea.sif library://lennoxl/umbridge/l2-sea:latest

run-server:
	# load umbridge server from local file
	singularity run --writable --bind ./umbridge-server.py:/ --pwd /  l2-sea.simg

pull-server:
	singularity pull l2-sea.sif library://lennoxl/umbridge/l2-sea:latest
	
	# convert image from read-only to modifiable
	singularity build l2-sea.simg l2-sea.sif

build-lb:
	# need sudo to build from definition file, so we have to add --remote flag to build from remote
	singularity build --remote --sandbox load-balancer.simg load-balancer.def
	
	# convert sandbox image to read-only image
	singularity build load-balancer.sif load-balancer.simg

	sinigularity push -U load-balancer.sif library://lennoxl/umbridge/load-balancer:latest

pull-lb:
	singularity pull --name load-balancer.sif

	# convert read-only image to sandbox image
	singularity build load-balancer.simg load-balancer.sif

run-lb:
	# bind local hq config to sandbox
	singularity run --bind ./hq_scripts:/ --writable --pwd / load-balancer/ $(port)