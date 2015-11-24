#Set base image to Ubuntu
FROM ubuntu:14.04 

#File Author / Maintainer
MAINTAINER opynios

RUN mkdir -p /db/maps 
COPY ./init_db.sh /db/
COPY ./maps-ssh-priv-key /db/
COPY ./sql_scripts /db/sql_scripts
WORKDIR /db

# Packages rquired for compiling maps, not needed now
#TODO: Fix and speed up compilation process for continuous integration in future.
#RUN apt-get update && \
#  apt-get install -y nodejs nodejs-legacy && \
#  apt-get install -y npm && \
#  npm install && \
#  apt-get install -y gdal-bin unzip wget && \
#  npm install mapshaper topojson -g 

ENV DEBIAN_FRONTEND=noninteractive

# Get permade maps.sql.7z file from maps hosting machine.
RUN apt-get update && \
    apt-get install -y mysql-server-5.6 mysql-client-core-5.6 mysql-client-5.6 openssh-client p7zip-full && \
    ls -la ./ && \
    chmod 600 ./maps-ssh-priv-key && \
    scp -oStrictHostKeyChecking=no -P 6277 -i ./maps-ssh-priv-key admin@maps.map-hosting.opynios.svc.tutum.io:/home/admin/maps/maps.sql.7z /db/maps/ 

WORKDIR /db/maps
RUN 7z e maps.sql.7z

WORKDIR /db
RUN sed -i.bak s/127\.0\.0\.1/0\.0\.0\.0/g /etc/mysql/my.cnf && \
    service mysql start && \
    ./init_db.sh localhost root "" && \
    mount && \
    ls /var/lib/mysql && \
    service mysql stop

CMD /usr/bin/mysqld_safe




