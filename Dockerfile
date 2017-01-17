FROM golang:1.8-alpine

COPY . /scripts
WORKDIR /scripts

RUN apk --update add git bash

RUN go get github.com/barnybug/cli53/cmd/cli53

RUN bash /scripts

ENTRYPOINT ["entrypoint.sh"]
