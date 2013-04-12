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

FILE_DIR="/root/storage"
FILE_PREFIX="vol"
LUN="$1"

DEV_OPTS=";nv_cache=1"

# Check parameters
if [ $# -lt 1 ]; then
	echo "Use a LUN number as parameter!"
	exit 1
fi

# Provide device and options
echo "add_device ${FILE_PREFIX}${LUN} filename=${FILE_DIR}/${FILE_PREFIX}${LUN}${DEV_OPTS}" \
	> /sys/kernel/scst_tgt/handlers/vdisk_fileio/mgmt

# Add LUN to target(s)
if [ $USE_TARGET_PER_PORT -eq 0 ]; then
	echo "add ${FILE_PREFIX}${LUN} ${LUN}" \
		> /sys/kernel/scst_tgt/targets/ib_srpt/${TNAME}/luns/mgmt
else
	echo "add ${FILE_PREFIX}${LUN} ${LUN}" \
		> /sys/kernel/scst_tgt/targets/ib_srpt/${TGID_P1}/luns/mgmt
	echo "add ${FILE_PREFIX}${LUN} ${LUN}" \
		> /sys/kernel/scst_tgt/targets/ib_srpt/${TGID_P2}/luns/mgmt
fi
