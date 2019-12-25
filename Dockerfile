FROM ubuntu

RUN apt-get update && apt-get install -y git bash curl

ADD . /sbp

ENV USER root
