for filename in $1/*; do
	[ -e "$filename" ] || continue
	kubectl cp $1/"$filename" $2:$(terraform output -raw mpi_file_dest)
done
