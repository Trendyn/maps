#Set base image to Ubuntu
FROM tutum/mysql:5.6 

#File Author / Maintainer
MAINTAINER opynios

ENV MYSQL_USER=oc
ENV MYSQL_PASS=opinions
ENV ON_CREATE_DB=opinions

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


# Get permade maps.sql.7z file from maps hosting machine.
RUN apt-get update && \
    apt-get install -y openssh-client p7zip-full && \
    ls -la ./ && \
    chmod 600 ./maps-ssh-priv-key && \
    scp -oStrictHostKeyChecking=no -P 6277 -i ./maps-ssh-priv-key admin@0b918df9-opynios.node.tutum.io:/home/admin/maps/maps.sql.7z /db/maps/ 

WORKDIR /db/maps
RUN 7z e maps.sql.7z

WORKDIR /db
RUN service mysql start && \
    ./init_db.sh opinions && \
    service mysql stop






