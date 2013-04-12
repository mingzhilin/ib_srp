#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
THCA1_GUID="0002c903004ed0b2"
THCA2_GUID="$THCA1_GUID"
TGID_P1="fe800000000000000002c903004ed0b3"
TGID_P2="fe800000000000000002c903004ed0b4"
PKEY="ffff"

IHCA1="mlx4_0"
IHCA2="mlx4_1"
IHCA_P1="1"
IHCA_P2="1"

FIRST_SD="b"

# Load ib_srp module with performance enhancement
modprobe ib_srp cmd_sg_entries=255

# Connect the targets
SRP1="id_ext=${THCA1_GUID},ioc_guid=${THCA1_GUID},dgid=${TGID_P1},pkey=${PKEY},service_id=${THCA1_GUID}"
SRP2="id_ext=${THCA2_GUID},ioc_guid=${THCA2_GUID},dgid=${TGID_P2},pkey=${PKEY},service_id=${THCA2_GUID}"
echo "${SRP1}" > /sys/class/infiniband_srp/srp-${IHCA1}-${IHCA_P1}/add_target
echo "${SRP2}" > /sys/class/infiniband_srp/srp-${IHCA2}-${IHCA_P2}/add_target

# Verify
sleep 2
lsscsi

# Check block layer timeouts
for sdev_dir in `ls -1d /sys/block/sd[${FIRST_SD}-z] 2>/dev/null`; do
	echo -n "timeout `basename ${sdev_dir}`: "
	cat "${sdev_dir}/device/timeout"
done
