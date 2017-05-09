#!/bin/bash

# Copyright (C) 2016 Mohamed El Morabity <melmorabity@fedoraproject.com>
#
# This module is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This software is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

# Modified by Derek Weitzel <dweitzel@cse.unl.edu> to add active and activating
# states as valid statuses.

STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_OK=0


if [ $# -ne 1 ]; then
    echo "Usage: ${0##*/} <service name>" >&2
    exit $STATE_UNKNOWN
fi

service=$1


status=$(systemctl is-enabled $service 2>/dev/null)
r=$?
if [ -z "$status" ]; then
    echo "ERROR: service $service doesn't exist"
    exit $STATE_CRITICAL
fi

if [ $r -ne 0 ]; then
    echo "ERROR: service $service is $status"
    exit $STATE_CRITICAL
fi

# Good states:
#  Active: active (running) since Tue 2017-05-09 10:46:01 CDT; 2min 29s ago
#  Active: activating (auto-restart) since Tue 2017-05-09 10:34:40 CDT; 14min ago
# Bad states:
#  Anything else...

systemctl_out=`systemctl status $service`
state=`echo $systemctl_out | grep -Po 'Active: \K[^ ]*'`

if [ ! "$state" = "active" ] && [ ! "$state" = "activating" ]; then
    echo "ERROR: service $service is not running: state = $state"
    exit $STATE_CRITICAL
fi

echo "OK: service $service is running in state: $state"
exit $STATE_OK
