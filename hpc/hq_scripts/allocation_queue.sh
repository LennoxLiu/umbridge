#! /bin/bash

# Note: For runs on systems without SLURM, replace the slurm allocator by
# hq worker start &


hq alloc add slurm --time-limit 10m \
                   --idle-timeout 3m \
                   --backlog 1 \
                   --workers-per-alloc 5 \
                   --max-worker-count 20 \
                   --cpus=1 \
                   -- -p "devel" --account=bw22J001 # Add any neccessary SLURM arguments
# Any parameters after -- will be passed directly to sbatch (e.g. credentials, partition, mem, etc.)
