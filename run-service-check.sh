#!/bin/sh

echo "Starting subversion..."

/usr/bin/svnserve -d --foreground -r /home/svn --listen-port 3690 &

CONFIG_INI="/opt/svnadmin/data/config.ini"
HTTPD_PID_FILE="/run/apache2/httpd.pid"
CONFIG_LDAP="UserViewProviderType=ldap"

rm -rf $HTTPD_PID_FILE

if [ ! -f "$CONFIG_INI" ]; then
   cp /opt/svnadmin/data/config.ini.tpl $CONFIG_INI
fi

sleep 3


echo "Starting apache2 loop check..."
while true;
do

      echo "Init loop..."

      SVNAuthFile="$(grep 'SVNAuthFile=' $CONFIG_INI | cut -b 13- | head -1)"
      SVNParentPath="$(grep 'SVNParentPath=' $CONFIG_INI | cut -b 15- | head -1)"
      REG_CONFIG_LDAP="$(grep "$CONFIG_LDAP" "$CONFIG_INI")"
            
      echo " SVNAuthFile = '$SVNAuthFile' "
      echo " SVNParentPath = '$SVNParentPath' "
      echo " REG_CONFIG_LDAP = '$REG_CONFIG_LDAP' "


      if [ "$REG_CONFIG_LDAP" == "$CONFIG_LDAP" ]; then      
            echo "LDAP config..."

            BindDN="$(grep 'BindDN=' $CONFIG_INI | cut -b 8- | head -1)"
            BindPassword="$(grep 'BindPassword=' $CONFIG_INI | cut -b 14- | head -1)"
            BaseDN="$(grep 'BaseDN=' $CONFIG_INI | cut -b 8- | head -1)"
            HostAddress="$(grep 'HostAddress=' $CONFIG_INI | cut -b 13-  | head -1)"
            SearchFilter="$(grep 'SearchFilter=' $CONFIG_INI | cut -b 14- | head -1)"
            Attributes="$(grep 'Attributes=' $CONFIG_INI | cut -b 12- | head -1)"

            echo " BindDN = '$BindDN' "
            echo " BindPassword = '$BindPassword' "
            echo " HostAddress = '$HostAddress' "
            echo " SearchFilter = '$SearchFilter' "
            echo " Attributes = '$Attributes' "

            echo "
                  LoadModule dav_svn_module /usr/lib/apache2/mod_dav_svn.so
                  LoadModule authz_svn_module /usr/lib/apache2/mod_authz_svn.so

                  <IfModule !ldap_module>
                        LoadModule ldap_module /usr/lib/apache2/mod_ldap.so
                  </IfModule>

                  <Location /svn>
                        DAV svn
                        SVNParentPath $SVNParentPath
                        SVNListParentPath On
                        AuthType Basic
                        AuthName \"Subversion Repository\"
                        AuthUserFile $SVNAuthFile
                        #AuthzSVNAccessFile /etc/subversion/subversion-access-control   
                        AuthBasicProvider ldap      
                        #AuthzLDAPAuthoritative on   
                        AuthLDAPBindDN \"$BindDN\"    
                        AuthLDAPBindPassword $BindPassword 
                        AuthLDAPURL \"${HostAddress}${BaseDN}?$Attributes?sub?$SearchFilter\"                  
                        Require valid-user
                        </Location>" > /etc/apache2/conf.d/dav_svn.conf 

      else
            echo "passwd config..."
            echo "
                  LoadModule dav_svn_module /usr/lib/apache2/mod_dav_svn.so
                  LoadModule authz_svn_module /usr/lib/apache2/mod_authz_svn.so
                  <Location /svn>
                        DAV svn
                        SVNParentPath $SVNParentPath
                        SVNListParentPath On
                        AuthType Basic
                        AuthName \"Subversion Repository\"
                        AuthUserFile $SVNAuthFile
                        AuthzSVNAccessFile /etc/subversion/subversion-access-control
                        Require valid-user
                  </Location>" > /etc/apache2/conf.d/dav_svn.conf 
      fi      
      
      /usr/sbin/apachectl restart 
      sleep 5   
      HTTPD_PID=$(cat $HTTPD_PID_FILE)   
      echo "Apache PID: $HTTPD_PID"
      echo "Wait changes..."
      inotifywait -e modify -q $CONFIG_INI
      echo "Sleeping 10..."
      sleep 10;
done;