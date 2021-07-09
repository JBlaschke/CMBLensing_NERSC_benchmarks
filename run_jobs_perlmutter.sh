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
#SBATCH -t $4


module use /pscratch/home/blaschke/julia/modulefiles/perlmutter
module load PrgEnv-gnu
module load julia python cudatoolkit
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/cray/pe/gcc-libs

#OpenMP settings:
export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread
export JULIA_MPI_TRANSPORT=MPI

unset PYTHONHOME
unset PYTHONPATH


#run the application:
srun -n $1 -G $2 julia run_chain.jl test_chain_$1_$2_$3.jld2
EOF
}


run_jobscript () {
    root=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

    pushd $root/benchmark/$1-$2-$3
    sbatch job_script.sh
    popd
}


mk_jobscript $1 $2 $3 $4
run_jobscript $1 $2 $3
