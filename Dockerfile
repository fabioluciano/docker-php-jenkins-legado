FROM centos:6.7

MAINTAINER Fábio Luciano <fabio.goisl@ctis.com.br>

ENV COMPOSER_HOME /usr/share/composer/

ADD http://pkg.jenkins-ci.org/redhat/jenkins.repo /etc/yum.repos.d/jenkins.repo
RUN rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

RUN yum update -y && \
  yum install -y java jenkins dejavu-fonts-common ant wget initscripts openssl openssl-devel && \
  yum groupinstall -y 'Development Tools' && \
  yum install -y php php-pear php-common php-opcache php-mbstring php-opcache php-mcrypt php-intl php-devel php-gd php-ldap php-mysql php-pdo php-pgsql php-xml && \ 
  yum clean all


COPY packages/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/
COPY packages/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp/
RUN yum install -y /tmp/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
RUN yum install -y /tmp/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN printf "\n" | pecl install oci8-2.0.11
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini

RUN printf "\n" | pecl install mongo
RUN echo "extension=mongo.so" > /etc/php.d/mongo.ini

RUN sed -i "s/^;date.timezone =$/date.timezone = \"America\/Sao_Paulo\"/" /etc/php.ini
RUN sed -i "s/^memory_limit =$/memory_limit = 1024M/" /etc/php.ini

COPY config/plugins.sh config/plugins.txt /tmp/
RUN chmod +x /tmp/plugins.sh
RUN /tmp/plugins.sh
RUN chown jenkins:jenkins -R /var/lib/jenkins/plugins

# PHP Related
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#RUN composer global require phpmetrics/phpmetrics:1.5.1
RUN composer global require squizlabs/php_codesniffer
RUN composer global require phpunit/phpunit:4.8.25
RUN composer global require sebastian/phpcpd:2.0.0
RUN composer global require sebastian/phpdcd
RUN composer global require pdepend/pdepend
RUN composer global require phploc/phploc:2.1.5
RUN composer global require theseer/phpdox:0.8.0
RUN composer global require phpmd/phpmd

RUN chmod a+rwx -R /usr/share/composer/cache
RUN ln -s /usr/share/composer/vendor/bin/* /usr/local/bin/

RUN install -p /var/lib/jenkins/jobs/php_template -d  -o jenkins -g jenkins
ADD https://raw.githubusercontent.com/fabioluciano/jenkins-php-builds/master/config.xml /var/lib/jenkins/jobs/php_template
RUN chown -R jenkins:jenkins /var/lib/jenkins/jobs -R

CMD /etc/init.d/jenkins start && tail -F /var/log/jenkins/jenkins.log
