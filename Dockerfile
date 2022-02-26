# Alpine Linux with s6 service management
FROM smebberson/alpine-base:3.2.0

# Install Apache2 and other stuff needed to access svn via WebDav
# Install svn
# Install utilities for SVNADMIN frontend
# Install utilities for monitoring
RUN apk add --no-cache apache2 apache2-utils apache2-webdav apache2-ldap mod_dav_svn &&\
    apk add --no-cache apache2-ldap &&\
	apk add --no-cache subversion  &&\
	apk add --no-cache wget patch unzip php7 php7-apache2 php7-session php7-json php7-ldap &&\
	apk add --no-cache php7-xml &&\	
	apk add --no-cache inotify-tools

# LDAP enable
RUN sed -i 's/;extension=ldap/extension=ldap/' /etc/php7/php.ini

# Create required folders
RUN mkdir -p /home/svn
RUN mkdir -p /opt
RUN mkdir -p /run/apache2
RUN mkdir -p /etc/subversion

# Create the authentication file for http access
RUN touch /etc/subversion/passwd

# Fixing https://github.com/mfreiholz/iF.SVNAdmin/issues/118
ADD patch/fix-svnadmin-php7-version.patch /tmp/

# Disable fields
ADD patch/disable-edit.patch /tmp/

# Getting SVNADMIN interface
RUN cd /opt/  &&\
    wget --no-check-certificate https://github.com/mfreiholz/iF.SVNAdmin/archive/stable-1.6.2.zip &&\    
    unzip stable-1.6.2.zip -d ./ &&\
    rm stable-1.6.2.zip &&\
    ln -s ./iF.SVNAdmin-stable-1.6.2 ./svnadmin &&\
	ln -s /opt/iF.SVNAdmin-stable-1.6.2 /var/www/localhost/htdocs/svnadmin &&\
    chmod -R 777 ./svnadmin/data &&\
    patch ./svnadmin/classes/util/global.func.php /tmp/fix-svnadmin-php7-version.patch -f &&\
    patch ./svnadmin/pages/settings/backend.html.php /tmp/disable-edit.patch -f &&\
    rm /tmp/*.patch

# Redirect output
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log


# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow


# Define persistents volumes
VOLUME [ "/home/svn", "/opt/svnadmin/data", "/etc/subversion" ]

# Set HOME in non /root folder
ENV HOME /home

# Default config file
ADD config/config.ini.tpl /opt/svnadmin/data/

# Add services configurations
ADD main-service /
ADD service/svnadmin-apache-check /etc/services.d/apache/run
ADD service/subversion /etc/services.d/subversion/run

# Expose ports for http and custom protocol access
EXPOSE 80 443 3690