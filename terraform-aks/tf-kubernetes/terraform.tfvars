cluster_name            = "tf-kubernetes"
worker_vm_size    = "m5n.xlarge"
launcher_vm_size  = "t3.medium"
container_name          = "wrf"
runscript               = <<RUNSCRIPT
cd /opt/wrf/data
sleep infinity
sed "s/ slots=/:/g" /etc/mpi/hostfile > /root/machines
time mpirun -v -n 4 -machine /root/machines \
            -iface eth0 \
            -launcher rsh \
            -launcher-exec /etc/mpi/kubexec.sh \
            ./IMB-MPI1
RUNSCRIPT
image_id                = "cornellcac/wrf:4.2.2"
#image_id                = "intel/oneapi-hpckit:devel-ubuntu18.04"
#image_id               = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
num_workers             = 1
slots_per_worker        = 2
#nfs_server_ip           = "172.20.135.120"
