FROM alpine

RUN apk -U add git bash curl

ADD . /sbp

ENV USER root
