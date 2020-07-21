mv namespace.tf staging
mv mpi-operator.tf staging
mv mpijob-crd.tf staging
tf destroy --auto-approve
