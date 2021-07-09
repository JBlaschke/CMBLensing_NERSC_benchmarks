#!/usr/bin/env bash

set -e


mk_jobscript () {
    root=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

    pushd $root

    mkdir -p benchmark/$1-$2-$3
    cp Manifest.toml benchmark/$1-$2-$3
    cp Project.toml benchmark/$1-$2-$3
    cp run_chain.jl benchmark/$1-$2-$3
    popd
    cat > $root/benchmark/$1-$2-$3/job_script.sh << EOF
#!/bin/bash
#SBATCH -N $3
#SBATCH -C gpu
#SBATCH -q special
#SBATCH -t $4
#SBATCH -A m1759
#SBATCH --exclusive


module purge
module use /global/cfs/cdirs/nstaff/blaschke/julia/modulefiles/cgpu
module load cgpu gcc cuda/11.3.0 openmpi julia/1.6.0-test python

#OpenMP settings:
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export JULIA_MPI_TRANSPORT=MPI

#run the application:
srun -n $1 -G $2 julia run_chain.jl test_chain_$1_$2_$3.jld2
EOF
}


run_jobscript () {
    root=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

    pushd $root/benchmark/$1-$2-$3
    module load cgpu
    sbatch job_script.sh
    popd
}


mk_jobscript $1 $2 $3 $4
run_jobscript $1 $2 $3
