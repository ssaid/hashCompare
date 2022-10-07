FROM alpine:latest
RUN apk add postgresql-dev make
WORKDIR /tmp