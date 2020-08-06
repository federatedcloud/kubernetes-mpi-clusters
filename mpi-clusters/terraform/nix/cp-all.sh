for filename in $1/*; do
	[ -e "$filename" ] || continue
	kubectl cp $1/"$filename" $2:$(echo var.mpi_file_dest | terraform console)
done
