#!/bin/bash
# added 2011-02-28 by Rgerhards
# This file is part of the rsyslog project, released  under GPLv3
echo ===============================================================================
echo \[imtcp-tls-basic.sh\]: testing imtcp in TLS mode - basic test
. $srcdir/diag.sh init
generate_conf
add_conf '
$ModLoad ../plugins/imtcp/.libs/imtcp
$MainMsgQueueTimeoutShutdown 10000

$DefaultNetstreamDriver gtls

# certificate files - just CA for a client
$IncludeConfig rsyslog.conf.tlscert
$InputTCPServerStreamDriverMode 1
$InputTCPServerStreamDriverAuthMode anon
$InputTCPServerRun 13514

$template outfmt,"%msg:F,58:2%\n"
$OMFileFlushOnTXEnd off
$OMFileFlushInterval 2
$OMFileAsyncWriting on
$OMFileIOBufferSize 16k
:msg, contains, "msgnum:" ./rsyslog.out.log;outfmt
'
echo \$DefaultNetstreamDriverCAFile $srcdir/tls-certs/ca.pem     >rsyslog.conf.tlscert
echo \$DefaultNetstreamDriverCertFile $srcdir/tls-certs/cert.pem >>rsyslog.conf.tlscert
echo \$DefaultNetstreamDriverKeyFile $srcdir/tls-certs/key.pem   >>rsyslog.conf.tlscert
startup
. $srcdir/diag.sh tcpflood -p13514 -m50000 -Ttls -Z$srcdir/tls-certs/cert.pem -z$srcdir/tls-certs/key.pem
shutdown_when_empty # shut down rsyslogd when done processing messages
wait_shutdown
seq_check 0 49999
exit_test
