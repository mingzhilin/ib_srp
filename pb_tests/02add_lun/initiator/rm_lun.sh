#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
LUN="$1"

# Check parameters
if [ $# -lt 1 ]; then
	echo "Use a LUN number as parameter!"
	exit 1
fi

# Remove given LUN on all SRP hosts
for shost_dir in `ls -1d /sys/class/srp_host/host*`; do
	shost_name=`basename ${shost_dir}`
	shost_num=${shost_name##host}
	echo 1 > "${shost_dir}/device/target${shost_num}:0:0/${shost_num}:0:0:${LUN}/delete"
done

# Verify
sleep 2
lsscsi
