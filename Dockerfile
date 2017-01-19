FROM golang:1.8-alpine

COPY . /scripts
WORKDIR /scripts

RUN apk --update add git bash curl py2-pip

RUN pip install awscli

RUN go get github.com/barnybug/cli53/cmd/cli53

RUN mv entrypoint.sh /usr/bin/route && chmod u+x /usr/bin/route

ENTRYPOINT ["route"]
