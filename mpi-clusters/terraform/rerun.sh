RUNNAME=$1
if [ ! -z ${RUNNAME} ]
then
	docker cp mpi-files tf_kubernetes_container:/home/nixuser/
	docker cp tf-kubernetes/staging/mpijob.tf tf_kubernetes_container:/home/nixuser/tf-kubernetes/staging
	docker cp tf-kubernetes/terraform.tfvars tf_kubernetes_container:/home/nixuser/tf-kubernetes
	docker exec -t tf_kubernetes_container nix-shell /home/nixuser/nix --run "/home/nixuser/nix/rerun.sh"
	docker cp tf_kubernetes_container:/home/nixuser/results.txt results/${RUNNAME}.txt
else
	echo Please title run
fi
