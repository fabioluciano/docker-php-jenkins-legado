FROM centos:6.7

MAINTAINER Fábio Luciano <fabio.goisl@ctis.com.br>

ADD http://pkg.jenkins-ci.org/redhat/jenkins.repo /etc/yum.repos.d/jenkins.repo
RUN rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

RUN yum groupinstall -y  'Development Tools' && yum install -y java jenkins dejavu-fonts-common wget initscripts \
  yum install -y php php-pear php-cli php-bcmath php-dba php-gd php-intl \
  php-imap php-ldap php-mbstring php-mysql php-devel php-ldap php-mysql php-odbc php-pgsql php-xml php-xmlrpc \
  php-mcrypt php-mssql php-posix php-soap php-tidy php-pecl-imagick php-pear-phing  php-dom php-pecl-xdebug

# PHP Related
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#RUN composer global require phpmetrics/phpmetrics
RUN composer global require squizlabs/php_codesniffer
RUN composer global require phpunit/phpunit:4.8.25
RUN composer global require sebastian/phpcpd:2.0.0
RUN composer global require sebastian/phpdcd:1.0.4
RUN composer global require pdepend/pdepend:1.1.1
RUN composer global require phploc/phploc:2.1.5
RUN composer global require theseer/phpdox:0.8.0
RUN composer global require phpmd/phpmd:2.0.0

COPY config/definepath.sh /etc/profile.d/definepath.sh

COPY packages/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/
RUN yum install -y /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN printf "\n" | pecl install oci8-2.0.11
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

VOLUME ["/docker/jenkins/config" : "/var/lib/jenkins", "/docker/jenkins/log" : "/var/log/jenkins"]

COPY config/plugins.sh config/plugins.txt /tmp/
RUN chmod +x /tmp/plugins.sh
RUN /tmp/plugins.sh
RUN chown jenkins:jenkins -R /var/lib/jenkins/plugins

CMD service jenkins start && tail -F /var/log/jenkins/jenkins.log
