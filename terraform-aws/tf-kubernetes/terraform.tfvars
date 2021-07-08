region                  = "us-east-1"
profile                 = "jcl393"
aws_credentials         = "jcl393_accessKeys.csv"
cluster_name            = "tf-kubernetes"
worker_instance_type    = "m5n.xlarge"
launcher_instance_type  = "t3.medium"
input_file_name         = "../mpi-files/WRF-script.sh"
remote_file_name        = "WRF-script.sh"
container_name          = "imb"
#runscript              = "export OMPI_MCA_btl_vader_single_copy_mechanism=none; cd /wrf/data/20210217_ncar_tutorial_2000_testing/WRF; time mpirun --allow-run-as-root -np 4 -mca btl ^openib wrf.exe"
#runscript               = "sleep infinity"
#runscript              = "cd /wrf/data; sed 's/slots=1/ /g' /etc/mpi/hostfile > /root/hostfile; time mpirun -v -np 2 -perhost 1 -f /root/hostfile -iface eth0 -launcher rsh -launcher-exec /etc/mpi/kubexec.sh ./IMB-MPI1"
runscript               = <<RUNSCRIPT
cd /wrf/data
sed "s/ slots=/:/g" /etc/mpi/hostfile > /root/machines
time mpirun -v -n 4 -ppn 2 -machine /root/machines \
            -iface eth0 \
            -launcher rsh \
            -launcher-exec /etc/mpi/kubexec.sh \
            ./IMB-MPI1
RUNSCRIPT
image_id                = "intel/oneapi-hpckit:devel-ubuntu18.04"
#image_id               = "cornellcac/wrf:3.8.1-fitch@sha256:ee2f88b1db2f72df03fb7627e5f25040caa02100600d7c0105d3e6ad6666ff3f"
#image_id               = "cornellcac/nix-mpi-benchmarks:a4f3cd63f6994703bbaa0636f4ddbcc87e83ea05"
num_workers             = 2
slots_per_worker        = 2
nfs_server_ip           = "172.20.24.125"
