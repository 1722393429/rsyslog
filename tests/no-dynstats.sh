#!/bin/bash
# added 2016-03-10 by singh.janmejay
# This file is part of the rsyslog project, released under ASL 2.0
echo ===============================================================================
echo \[no-dynstats.sh\]: test for verifying stats are reported correctly in legacy format in absence of any dynstats buckets being configured
. $srcdir/diag.sh init
generate_conf
add_conf '
ruleset(name="stats") {
  action(type="omfile" file="./rsyslog.out.stats.log")
}

module(load="../plugins/impstats/.libs/impstats" interval="1" severity="7" resetCounters="on" Ruleset="stats" bracketing="on")

action(type="omfile" file="./rsyslog.out.log")
'
startup
. $srcdir/diag.sh wait-for-stats-flush 'rsyslog.out.stats.log'
echo doing shutdown
shutdown_when_empty
echo wait on shutdown
wait_shutdown
. $srcdir/diag.sh custom-content-check 'global: origin=dynstats' 'rsyslog.out.stats.log'
exit_test
