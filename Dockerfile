FROM rocker/rstudio

MAINTAINER Divyam Malay Shah <divyam096@gmail.com>

LABEL Description="This image is used to set up RStudio Server"

RUN apt-get update && apt-get install -y --force-yes \
libpq-dev \
postgresql-client 

