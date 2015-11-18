#Set base image to Ubuntu
FROM tutum/mysql 

#File Author / Maintainer
MAINTAINER opynios

ENV MYSQL_USER=oc
ENV MYSQL_PASS=opinions
ENV ON_CREATE_DB=opinions

RUN mkdir -p /db/maps 
COPY ./create_db.sh /db/
COPY ./sql_scripts /db/sql_scripts
WORKDIR /db
RUN service mysql start && ./create_db.sh 

COPY ./maps /db/maps
WORKDIR /db/maps
RUN apt-get update && \
  apt-get install -y nodejs nodejs-legacy && \
  apt-get install -y npm && \
  npm install && \
  apt-get install -y gdal-bin unzip wget && \
  npm install mapshaper topojson -g 

WORKDIR /db/maps/WORLD
RUN service mysql start && node ../makemaps.js

COPY ./init_db.sh /db
WORKDIR /db
RUN service mysql start && ./init_db.sh opinions 






