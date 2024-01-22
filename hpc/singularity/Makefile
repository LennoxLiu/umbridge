all: run-server


build-server:
	singularity build --remote --sandbox l2-sea/ l2-sea.def

run-server:
	singularity run --writable --pwd /  l2-sea/

build-lb:
	singularity build load-balancer.sif load-balancer.def