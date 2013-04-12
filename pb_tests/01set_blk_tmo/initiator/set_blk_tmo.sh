#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
TMO=$1

RPORT_DIR="/sys/class/srp_remote_ports"
BLK_TMO_FILE="blk_rq_tmo"

FIRST_SD="b"

# Check parameters
if [ $# -lt 1 ]; then
	echo "Use a number in seconds as parameter!"
	exit 1
fi

# Set block layer timeouts
for rport in `ls -1 "${RPORT_DIR}"`; do
    echo ${TMO} > "${RPORT_DIR}/${rport}/${BLK_TMO_FILE}"
done

# Check block layer timeouts
for sdev_dir in `ls -1d /sys/block/sd[${FIRST_SD}-z] 2>/dev/null`; do
   echo -n "timeout `basename ${sdev_dir}`: "
   cat "${sdev_dir}/device/timeout"
done
