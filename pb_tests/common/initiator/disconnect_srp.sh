#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
USE_DELETE=0

RPORT_DIR="/sys/class/srp_remote_ports"

# Disconnect all targets
if [ $USE_DELETE -ne 0 ]; then
	for rport in `ls -1 "${RPORT_DIR}" 2>/dev/null`; do
		echo 1 > "${RPORT_DIR}/${rport}/delete"
	done
	sleep 2
fi
modprobe -r ib_srp
