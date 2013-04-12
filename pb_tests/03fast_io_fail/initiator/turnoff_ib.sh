#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

# Init
START=`date +%s`
TIME=0
ELAP=0        # elapsed time in seconds

# Config
DURA=$1       # down time in seconds
HCA="mlx4_0"
LPORT=1       # local port - for connection to SM
LLID=`ibaddr -C $HCA -L -P $LPORT | cut -d ' ' -f 3`  # get local LID

# We use the local LID as destination LID for 'ibportstate' 'reset' here.
# Furthermore, we use the local port as destination port.
# ATTENTION: DO NOT DISABLE THE PORT YOU ARE CONNECTED TO THE SM WITH!
DLID=$LLID
DPORT=$LPORT

# Check parameters
if [ $# -lt 1 ]; then
        echo "Use a number in seconds as duration parameter!"
        exit 1
fi

# The 'reset' command is run in a fast loop as the IB interface would
# come up automatically otherwise.
while [ $ELAP -lt $DURA ]; do
	ibportstate -C $HCA -P $LPORT $DLID $DPORT reset

	TIME=`date +%s`
	let "ELAP = $TIME - $START"
done

# re-enable the IB port
ibportstate -C $HCA -P $LPORT $DLID $DPORT enable

echo "Process finished after $ELAP seconds"
