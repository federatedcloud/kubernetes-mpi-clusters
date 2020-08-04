sleep 1
while [ ! $(kubectl get $1 -o json \
		| jq .status.containerStatuses[0].ready) == "true" ]
do
	sleep 0.1
done
