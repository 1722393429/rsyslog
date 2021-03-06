#!/bin/bash
. $srcdir/diag.sh init
generate_conf
add_conf '
$ModLoad ../contrib/omtcl/.libs/omtcl
$template tcldict, "message \"%msg:::json%\" fromhost \"%HOSTNAME:::json%\" facility \"%syslogfacility-text%\" priority \"%syslogpriority-text%\" timereported \"%timereported:::date-rfc3339%\" timegenerated \"%timegenerated:::date-rfc3339%\" raw \"%rawmsg:::json%\" tag \"%syslogtag:::json%\""
'
add_conf "*.* :omtcl:$srcdir/omtcl.tcl,doAction;tcldict
"
startup
echo 'injectmsg litteral <167>Mar  1 01:00:00 172.20.245.8 tag hello world' | \
	./diagtalker || error_exit $?
echo doing shutdown
shutdown_when_empty
echo wait on shutdown
wait_shutdown
. $srcdir/diag.sh content-check 'HELLO WORLD'
cat rsyslog.out.log
exit_test
