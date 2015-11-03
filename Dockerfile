FROM ubuntu:trusty
MAINTAINER "Youngho Byun (echoes)" <elend80@gmail.com>

ENV TERM xterm

RUN echo Asia/Seoul | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update
#RUN apt-get install -y software-properties-common python-software-properties
RUN apt-get install -y nano wget dialog net-tools curl git supervisor

# NGINX Install

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" > /etc/apt/sources.list.d/nginx.list
RUN apt-get update
RUN apt-get install -y nginx

ADD default /etc/nginx/sites-available/default

# HHVM Install

RUN apt-get autoclean
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN echo deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main | tee /etc/apt/sources.list.d/hhvm.list

RUN apt-get update && \
    apt-get install -y hhvm && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/share/hhvm/install_fastcgi.sh

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chown root:root /etc/supervisor/conf.d/supervisord.conf

RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord"]
