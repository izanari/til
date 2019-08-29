#!/bin/bash

set -ex;

CMSDIR=/var/www/powercms/mt
PIDFILE=/var/www/powercms/mt/powercms.pid


# mt-config.cgiへ追記する
cp ${CMSDIR}/mt-config.cgi ${CMSDIR}/mt-config.cgi.BAK
cat << EOL | tee -a ${CMSDIR}/mt-config.cgi
PIDFilePath ${PIDFILE}
SQLSetNames 0 
DefaultLanguage ja
EOL

# supervisorのデフォルト設定ファイルを生成する
/usr/local/bin/echo_supervisord_conf > /etc/supervisord.conf

cat << EOL | tee -a /etc/supervisord.conf
[include]
files = /etc/supervisor-powercms.conf
EOL

mkdir /var/log/supervisor
chown apache:root /var/log/supervisor
touch /var/log/supervisor/powercms.log
touch /var/log/supervisor/powercms-error.log
chown apache:root /var/log/supervisor/*.log

# PowerCMS用の設定を生成する
cat << EOL | tee /etc/supervisor-powercms.conf
[program:powercms]
command=/usr/local/bin/starman -l 127.0.0.1:5000 --workers 2 --pid ${PIDFILE} ./mt.psgi
process_name=%(program_name)s ; process_name expr (default %(program_name)s)
numprocs=1                    ; number of processes copies to start (def 1)
directory=${CMSDIR}
umask=022                     ; umask for process (default None)
;priority=999                  ; the relative start priority (default 999)
autostart=true                ; start at supervisord start (default: true)
startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
startretries=3                ; max # of serial start failures when starting (default 3)
autorestart=unexpected        ; when to restart if exited after running (def: unexpected)
exitcodes=0,2                 ; 'expected' exit codes used with autorestart (default 0,2)
stopsignal=QUIT               ; signal used to kill process (default TERM)
stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
stopasgroup=false             ; send stop signal to the UNIX process group (default false)
killasgroup=false             ; SIGKILL the UNIX process group (def false)
user=apache                  ; setuid to this UNIX account to run the program
;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
stdout_logfile=/var/log/supervisor/powercms.log
stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
stderr_logfile=/var/log/supervisor/powercms-error.log
stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
;stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;environment=A="1",B="2"       ; process environment additions (def no adds)
;serverurl=AUTO                ; override serverurl computation (childutils)
EOL

cat << EOL | tee /etc/init.d/supervisord
#!/bin/bash
#
# supervisord   Supervisord
#
# chkconfig: - 85 15
# description: Auto-starts supervisord
# processname: supervisord
# pidfile: /var/run/supervisord.pid

SUPERVISORD=/usr/local/bin/supervisord
CONF=/etc/supervisord.conf
SUPERVISORCTL=/usr/local/bin/supervisorctl

case $1 in
start)
        echo -n "Starting supervisord: "
        $SUPERVISORD -c $CONF
        echo
        ;;
stop)
        echo -n "Stopping supervisord: "
        $SUPERVISORCTL shutdown
        echo
        ;;
restart)
        echo -n "Stopping supervisord: "
        $SUPERVISORCTL shutdown
        echo
        echo -n "Starting supervisord: "
        $SUPERVISORD -c $CONF
        echo
        ;;
esac
EOL

chkconfig --level 345 supervisord on
/etc/init.d/supervisord start
