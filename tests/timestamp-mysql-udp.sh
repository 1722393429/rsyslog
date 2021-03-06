#!/bin/bash
# add 2018-06-25 by Pascal Withopf, released under ASL 2.0
. $srcdir/diag.sh init
generate_conf
add_conf '
module(load="../plugins/imudp/.libs/imudp")
input(type="imudp" port="13514")

template(name="outfmt" type="string" string="%timestamp:::date-mysql%\n")

:syslogtag, contains, "su" action(type="omfile" file="rsyslog.out.log"
				  template="outfmt")

'
startup
. $srcdir/diag.sh tcpflood -m1 -T "udp" -M "\"<34>1 2003-01-23T12:34:56.003Z mymachine.example.com su - ID47 - MSG\""
shutdown_when_empty
wait_shutdown

echo '20030123123456' | cmp - rsyslog.out.log
if [ ! $? -eq 0 ]; then
  echo "invalid response generated, rsyslog.out.log is:"
  cat rsyslog.out.log
  error_exit  1
fi;

exit_test
