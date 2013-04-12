#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
USE_TARGET_PER_PORT=0

TNAME="ib_srpt_target_0"
TGID_P1="fe80:0000:0000:0000:0002:c903:004e:d0b3"
TGID_P2="fe80:0000:0000:0000:0002:c903:004e:d0b4"

FILE_PREFIX="vol"
LUN="$1"

# Check parameters
if [ $# -lt 1 ]; then
	echo "Use a LUN number as parameter!"
	exit 1
fi

# Delete LUN from target(s)
if [ $USE_TARGET_PER_PORT -eq 0 ]; then
	echo "del ${LUN}" \
		> /sys/kernel/scst_tgt/targets/ib_srpt/${TNAME}/luns/mgmt
else
	echo "del ${LUN}" \
		> /sys/kernel/scst_tgt/targets/ib_srpt/${TGID_P1}/luns/mgmt
	echo "del ${LUN}" \
		> /sys/kernel/scst_tgt/targets/ib_srpt/${TGID_P2}/luns/mgmt
fi

# Delete device
echo "del_device ${FILE_PREFIX}${LUN}" \
	> /sys/kernel/scst_tgt/handlers/vdisk_fileio/mgmt
