#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
LUN="$1"

FIRST_SD="b"

# Check parameters
if [ $# -lt 1 ]; then
	echo "Use a LUN number as parameter!"
	exit 1
fi

# Scan given LUN on all SRP hosts
for shost_dir in `ls -1d /sys/class/srp_host/host*`; do
	shost_name=`basename ${shost_dir}`
	echo "0 0 ${LUN}" > "${shost_dir}/device/scsi_host/${shost_name}/scan"
done

# Verify
sleep 2
lsscsi

# Check block layer timeouts
for sdev_dir in `ls -1d /sys/block/sd[${FIRST_SD}-z] 2>/dev/null`; do
	echo -n "timeout `basename ${sdev_dir}`: "
	cat "${sdev_dir}/device/timeout"
done
