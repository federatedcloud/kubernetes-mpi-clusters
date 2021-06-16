kubectl wait --for=condition=Ready pods $1 --timeout=60s -n mpi-operator > /dev/null
while [ $(kubectl get pods $1 -n mpi-operator -o jsonpath={.status.phase}) != "Running" ]
do
	sleep 0.1
done
echo $1 is ready
