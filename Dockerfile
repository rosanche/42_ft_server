FROM debian:buster

COPY /src/test.sh ./
COPY /src/config_nginx ./root/

#INSTALL
RUN apt-get update -y && apt-get upgrade && apt-get install -y wget nginx mariadb-server mariadb-client 
RUN apt install -y php7.3 php7.3-fpm php7.3-mysql php-common php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline \
php-mbstring
RUN apt-get install -y openssl
RUN apt-get install -y vim

#NGINX
RUN mkdir -p  /var/www/html
COPY /src/index.html /var/www/html/
COPY /src/config_nginx /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

#SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/server.key -out /etc/ssl/certs/server.crt -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=localhost" 
COPY src/dhparam.pem /etc/nginx/dhparam.pem
COPY src/ssl-params.conf /etc/nginx/snippets/
COPY src/self-signed.conf /etc/nginx/snippets/

#MySQL
RUN service mysql start
RUN mysql --version

#WORDPRESS
RUN mkdir -p /var/www/html/example
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -zxvf latest.tar.gz --strip-components=1 -C /var/www/html/example
COPY src/wp-config.php /var/www/html/example/wp-config.php

#PHP
RUN service php7.3-fpm start
RUN mkdir -p var/www/html/phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN tar -zxvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin
COPY src/config.inc.php var/www/html/phpmyadmin/

CMD bash test.sh 
