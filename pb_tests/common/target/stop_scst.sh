#!/bin/bash
#
# Copyright ProfitBricks GmbH - All rights reserved
#
# Author:  Sebastian Riemer <sebastian.riemer@profitbricks.com>
# License: GPLv2

modprobe -r ib_srpt
modprobe -r scst_vdisk
modprobe -r scst
