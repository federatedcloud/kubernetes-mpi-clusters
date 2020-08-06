kubectl wait $1 --for=condition=Ready --timeout=60s
while [ ! $(kubectl get $1 -o json \
	| jq .status.containerStatuses[0].ready) == "true" ]
do
	sleep 0.1
done
echo $1 is ready
