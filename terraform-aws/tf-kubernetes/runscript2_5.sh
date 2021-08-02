#!/bin/bash
cd /opt/wrf/data
sed "s/ slots=2/:96/g" /etc/mpi/hostfile > /root/machines
rm -r /opt/wrf/data/WRF
cp -r /opt/wrf/WRF /opt/wrf/data/WRF/
for realfile in $( cat /opt/wrf/data/CONUS2.5/CONUS2.5km_files ); do
  ln -s /opt/wrf/data/v4_bench_conus2.5km/${realfile} \
        /opt/wrf/data/WRF/run/$(basename $realfile)
done
cp /opt/wrf/data/v4_bench_conus2.5km/namelist.input /opt/wrf/data/WRF/run/namelist.input
time mpirun -n 384 -machinefile /root/machines \
  -iface eth0 \
  -launcher rsh \
  -launcher-exec /etc/mpi/kubexec.sh \
  -wdir /opt/wrf/data/WRF/run/ \
  /opt/wrf/data/WRF/run/wrf.exe
mv /opt/wrf/data/WRF/run/wrfout_d01_2019-11-27_00:00:00 \
   /opt/wrf/data/WRF_OUT/wrfoutC2.5-$(date +"%m-%d-%H:%M")
