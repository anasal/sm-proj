FROM ubuntu:14.04
MAINTAINER Anas Al-Selwi "s316818@stud.hioa.no"
RUN apt-get update
RUN apt-get install -y apache2
RUN apt-get -y install libapache2-mod-php5 php5-mysql
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ONBUILD ADD ./index.html /var/www/html/
EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2ctl"]
CMD [ "-D","FOREGROUND"]
