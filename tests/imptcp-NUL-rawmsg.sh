#!/bin/bash
# addd 2016-05-13 by RGerhards, released under ASL 2.0

. $srcdir/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imptcp/.libs/imptcp")
input(type="imptcp" port="13514")

template(name="outfmt" type="string" string="%rawmsg%\n")
:msg, contains, "msgnum:" action(type="omfile" template="outfmt"
			         file="rsyslog.out.log")
'
startup
echo '<167>Mar  6 16:57:54 172.20.245.8 test: msgnum:0 X test message
<167>Mar  6 16:57:54 172.20.245.8 Xtest: msgnum:1 test message' | tr X '\000' > rsyslog.input
. $srcdir/diag.sh tcpflood -B -I rsyslog.input
shutdown_when_empty
wait_shutdown
echo '<167>Mar  6 16:57:54 172.20.245.8 test: msgnum:0 #000 test message
<167>Mar  6 16:57:54 172.20.245.8 #000test: msgnum:1 test message' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid output generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  exit 1
fi;
exit_test
