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
NUM_FILES=3

DEV_OPTS=";nv_cache=1"

# Load drivers
modprobe scst
modprobe scst_vdisk
mkdir -p /var/lib/scst/pr

if [ $USE_TARGET_PER_PORT -eq 0 ]; then
	modprobe ib_srpt
else
	modprobe ib_srpt one_target_per_port=1
fi

# Provide devices and options
for ((i=1; i<=$NUM_FILES; i++)); do
	echo "add_device ${FILE_PREFIX}${i} filename=${FILE_DIR}/${FILE_PREFIX}${i}${DEV_OPTS}" \
		> /sys/kernel/scst_tgt/handlers/vdisk_fileio/mgmt
done

if [ $USE_TARGET_PER_PORT -eq 0 ]; then
	# add LUNs to SRP target
	for ((i=1; i<=$NUM_FILES; i++)); do
		 echo "add ${FILE_PREFIX}${i} ${i}" \
			> /sys/kernel/scst_tgt/targets/ib_srpt/${TNAME}/luns/mgmt
	done

	# enable target
	echo "1" > /sys/kernel/scst_tgt/targets/ib_srpt/${TNAME}/enabled

else
	# add LUNs to SRP target at port 1
	for ((i=1; i<=$NUM_FILES; i++)); do
		echo "add ${FILE_PREFIX}${i} ${i}" \
			> /sys/kernel/scst_tgt/targets/ib_srpt/${TGID_P1}/luns/mgmt
	done

	# add LUNs to SRP target at port 2
	for ((i=1; i<=$NUM_FILES; i++)); do
		echo "add ${FILE_PREFIX}${i} ${i}" \
			> /sys/kernel/scst_tgt/targets/ib_srpt/$TGID_P2/luns/mgmt
	done

	# enable targets
	echo "1" > /sys/kernel/scst_tgt/targets/ib_srpt/$TGID_P1/enabled
	echo "1" > /sys/kernel/scst_tgt/targets/ib_srpt/$TGID_P2/enabled
fi
