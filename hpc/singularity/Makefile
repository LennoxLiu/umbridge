all: pull-server pull-lb run-lb

# If port is not set, use the default value "4242"
port ?= 4242

build-server:
	# remove old image if it exists
	rm l2-sea.simg -rf
	rm l2-sea.sif

	# create read-only image from definition file
	singularity build --remote l2-sea.sif l2-sea.def

	# publish image to singularity hub
	# singularity push -U l2-sea.sif library://lennoxl/umbridge/l2-sea:latest

run-server:
	# create output folder if it doesn't exist
	mkdir -p ./output

	# load umbridge server from local file
	singularity run --writable --bind ./umbridge-server:/umbridge-server --bind ./output:/output --pwd /umbridge-server  l2-sea.simg $(port)

pull-server:
	#singularity pull l2-sea.sif library://lennoxl/umbridge/l2-sea:latest
	
	# convert image from read-only to modifiable
	singularity build --sandbox l2-sea.simg l2-sea.sif

build-lb:
	# remove old image if it exists
	rm load-balancer.simg -rf
	rm load-balancer.sif

	# need sudo to build from definition file, so we have to add --remote flag to build from remote
	singularity build --remote load-balancer.sif load-balancer.def

	# publish image to singularity hub
	# singularity push -U load-balancer.sif library://lennoxl/umbridge/load-balancer:latest

pull-lb:
	#singularity pull load-balancer.sif library://lennoxl/umbridge/load-balancer:latest

	# convert read-only image to sandbox image
	singularity build --sandbox load-balancer.simg load-balancer.sif

run-lb:
	# bind local hq config to sandbox (Secondly, bind the local folder to working folder in sandbox)
	singularity run --bind ./load-balancer_singularity:/load-balancer_singularity --writable --pwd /load-balancer_singularity load-balancer.simg $(port)