DEST=$(terraform output -raw mpi_file_dest)
for filename in $1/*; do
	[ -e ${filename} ] || continue
	kubectl cp $1/${filename} $2:${DEST}/${filename##*/} -n mpi-operator
        echo ${filename} copied to ${DEST}/${filename##*/}
done
