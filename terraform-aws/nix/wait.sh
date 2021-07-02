#!/nix/store/f475vzr63m77nfww608dni9385ahpvl1-nix-2.3.12/bin/nix-shell
## Waits until the pod passed as $1 has been created
kubectl wait --for=condition=Ready pods $1 --timeout=60s -n mpi-operator > /dev/null
## Waits until the container the pod $1 is ready
while [ $(kubectl get pods $1 -n mpi-operator -o jsonpath={.status.phase}) != "Running" ]
do
	sleep 0.1
done
echo $1 is ready
