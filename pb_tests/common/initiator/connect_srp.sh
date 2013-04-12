#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
RETRIES=$1

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

ADD_SYSFS="add_target"
DQR_SYSFS="def_qp_retries"
QPR_SYSFS="qp_retries"

# Check parameters
if [ $# -lt 1 ]; then
	echo "Use a number of QP retries as parameter!"
	exit 1
fi

# Load ib_srp module with performance enhancement
modprobe ib_srp cmd_sg_entries=255

# Set default QP retries
echo "$RETRIES" > /sys/class/infiniband_srp/srp-${IHCA1}-${IHCA_P1}/${DQR_SYSFS} || exit 1
echo "$RETRIES" > /sys/class/infiniband_srp/srp-${IHCA2}-${IHCA_P2}/${DQR_SYSFS} || exit 1

# Check default QP retries
echo "Checking default QP retries:"
echo -n "${IHCA1}-${IHCA_P1}: "
cat /sys/class/infiniband_srp/srp-${IHCA1}-${IHCA_P1}/${DQR_SYSFS}
echo -n "${IHCA2}-${IHCA_P2}: "
cat /sys/class/infiniband_srp/srp-${IHCA2}-${IHCA_P2}/${DQR_SYSFS}

# Connect the targets
echo "Connecting..."
SRP1="id_ext=${THCA1_GUID},ioc_guid=${THCA1_GUID},dgid=${TGID_P1},pkey=${PKEY},service_id=${THCA1_GUID}"
SRP2="id_ext=${THCA2_GUID},ioc_guid=${THCA2_GUID},dgid=${TGID_P2},pkey=${PKEY},service_id=${THCA2_GUID}"
echo "${SRP1}" > /sys/class/infiniband_srp/srp-${IHCA1}-${IHCA_P1}/${ADD_SYSFS}
echo "${SRP2}" > /sys/class/infiniband_srp/srp-${IHCA2}-${IHCA_P2}/${ADD_SYSFS}

# Check set QP retries
echo "Checking set QP retries:"
for srp_host in `ls -1d /sys/class/srp_host/*/device/scsi_host/*`; do
	echo -n "qp_retries `basename ${srp_host}`: "
	cat "${srp_host}/${QPR_SYSFS}"
done

# Verify
sleep 2
lsscsi

# Check block layer timeouts
for sdev_dir in `ls -1d /sys/block/sd[${FIRST_SD}-z] 2>/dev/null`; do
	echo -n "timeout `basename ${sdev_dir}`: "
	cat "${sdev_dir}/device/timeout"
done
