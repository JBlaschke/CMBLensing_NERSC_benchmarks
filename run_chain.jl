#/usr/bin/env julia

# init
using Distributed, CMBLensing, CUDA, MPIClusterManagers
CMBLensing.init_MPI_workers()

# load simulation
@unpack ds = load_sim(
    Nside   = 256,
    T       = Float32,
    θpix    = 3,
    pol     = :P,
)

# run chain
chains = sample_joint(
    ds;
    storage          = CuArray,
    nsamps_per_chain = 100,
    nfilewrite       = 20,
    nsavemaps        = 20,
    filename         = "test_chain.jld2",
    resume           = false,
    θrange           = (Aϕ = range(0.8, 1.2, length=25), r = range(0.01 ,0.2, length=25)),
    progress         = :summary,
)
