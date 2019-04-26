#======== REQUIRED SETTINGS ==========

CGIPath        /powercms4/mt/
StaticWebPath  /powercms4/mt/mt-static/
StaticFilePath /var/www/powercms4/mt/mt-static

#======== DATABASE SETTINGS ==========

ObjectDriver DBI::mysql
Database powercms4
DBUser cmsman
DBPassword pass_pass_pass
DBHost localhost

#======== MAIL =======================
EmailAddressMain yourmailaddress
MailTransfer smtp
SMTPServer localhost
SMTPPort 25

DefaultLanguage ja

ImageDriver ImageMagick

# === ここからは手動で設定します
PIDFilePath /var/www/powercms4/mt/powercms4.pid

PluginPath plugins
PluginPath plugins_customized
AllowPluginDirectInstall 1
PreviewInNewWindow 1
ForcePreviewInNewWindow 1
AutoSaveFrequency 0
TransparentProxyIPs 1

#AdminCGIPath https://yourdomain/powercms4/mt/

#PowerCMSFilesDir /var/www/powercms4/powercms_files

AssetStatusUnpublishIfNoOtherPublished 1
AssetStatusSyncStatus 0

PasswordExpired 1
PasswordExpiredPeriod 90

#MemcachedNamespace prod-cms
##MemcachedServers 127.0.0.1:11211

DeniedAssetFileExtensions ascx,asis,asp,aspx,bat,cfc,cfm,cgi,cmd,com,cpl,dll,exe,htm,jhtml,jsb,jsp,mht,mhtml,msi,php2,php3,php4,php5,phps,phtm,phtml,pif,pl,pwml,py,reg,scr,sh,shtm,shtml,vbs,vxd,pm,so,rb,htc

HTMLUmask 0002
DirUmask 0002
UploadUmask 0112

CGIMaxUpload 500000000

AssetCacheDir thumbnail

# For Copy2Public
#AllowCopy2PublicStagingRoot /var/www/staging/html
#AllowCopy2PublicDirectSync 1
#AllowCopy2PublicPublishRoot /var/www/production/html