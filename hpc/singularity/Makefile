all: run-server

# If port is not set, use the default value "4242"
port ?= 4242

build-server:
	singularity build --remote --sandbox l2-sea/ l2-sea.def

run-server:
	singularity run --writable --pwd /  l2-sea/

build-lb:
	singularity build --remote --sandbox load-balancer/ load-balancer.def

run-lb:
	# bind local hq config to sandbox
	singularity run --bind ./hq_scripts:/ --writable --pwd / load-balancer/ $(port)