#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Config
SRP_DEVS=`ls -1 /dev/sd[b-z]`

# Init
SCSI_IDS=""
SCSI_DEVS=""

# Get the SCSI IDs
for sdev in $SRP_DEVS; do
	SRP_IDS="${SRP_IDS} `/lib/udev/scsi_id --whitelisted ${sdev}`"
	SCSI_DEVS="${SCSI_DEVS} `basename ${sdev}`"
done

# Remove multipath maps and paths
for i in $SCSI_IDS; do
	multipathd del map $i >/dev/null 2>&1
done

for i in $SCSI_DEVS; do
	multipathd del path $i >/dev/null 2>&1
done

# We can't trust multipathd output, so check it here.
echo "check:"
multipathd show maps
multipathd show paths
if [ "`ls /dev/dm-* 2>/dev/null`" != "" ]; then echo "FAIL"; exit 1; fi
echo "done"
