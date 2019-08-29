#!/bin/sh

CMSDIR=/var/www/powercms/mt
MTROOT=/powercms/mt
DOCROOT=/var/www/html
## 環境依存のため書き換えが必要
## EC2 roleへの権限付与をしておくこと
S3OBJECT=s3://hogehoge/powercms/PowerCMS5.12-Professional.zip

cd /var/www; aws s3 cp ${S3OBJECT} .
unzip -q PowerCMS5.12-Professional.zip
ln -s ./PowerCMS5.12-Professional ./powercms

cd /var/www/powercms/options; cp -pR ./* ${CMSDIR}
cd /var/www/powercms/options_legacy; cp -pR ./* ${CMSDIR}

chown apache:root ${CMSDIR}
chown apache:root ${CMSDIR}/mt-static/support
chown apache:root ${DOCROOT}
chown apache:root ${CMSDIR}/powercms_files/

## 443 で設定したほうがよい。これはサンプルファイルのため80のみとする
cat << EOL | tee /etc/httpd/conf.d/virtualhost-powercms.conf
LogFormat "%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" x-combinedio

ExtendedStatus On
<Location /server-status>
	SetHandler server-status
        <RequireAny>
        	Require ip 127.0.0.1
        </RequireAny>
</Location>
<VirtualHost *:80>
        DocumentRoot	${DOCROOT}
        ErrorLog        /var/log/httpd/cms_error_log
        CustomLog       /var/log/httpd/cms_access_log x-combinedio
        TimeOut	120

        <directory ${DOCROOT}>
            Options -Indexes +Includes +FollowSymLinks
            AllowOverride All
            <RequireAll>
                Require method GET POST
            </RequireAll>
        </directory>
        <Location "${MTROOT}/">
            AllowOverride All
        </Location>
        Alias       ${MTROOT}/mt-static/   "${CMSDIR}/mt-static/"
        ScriptAlias ${MTROOT}/     "${CMSDIR}/"
        AddHandler cgi-script .cgi
        ProxyRequests    Off
        #ProxyPass       ${MTROOT}/  http://localhost:5000/powercms/mt/
        #ProxyPassReverse        ${MTROOT}/  http://localhost:5000/powercms/mt/
        ProxyTimeout 1200
</VirtualHost>
EOL




systemctl enable httpd;
systemctl start httpd;
systemctl status httpd;

systemctl enable mariadb;
systemctl start mariadb;
systemctl status mariadb;
