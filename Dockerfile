################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######
######
######	Dockerfile for Hydroxide / Proton Mail Server
######
######
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Build Hydroxide	
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# builder OS
FROM golang:1-alpine as builder

# update / dependencies  
RUN apk --update upgrade \
&& apk --no-cache --no-progress add git make gcc musl-dev \
&& rm -rf /var/cache/apk/*

# docker container settings
ENV GOPATH /go

# copy source code into builder
WORKDIR /src
COPY . .

# build hydroxide
RUN go build ./cmd/hydroxide && go install ./cmd/hydroxide


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Copy to container
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# container OS
FROM alpine:3.9

USER root

EXPOSE 1025
EXPOSE 1143

# update / dependencies
RUN apk --update upgrade \
    && apk --no-cache add ca-certificates bash openrc jq \
    && rm -rf /var/cache/apk/*

# email variables; either pass these from your docker-compose file OR uncomment and insert below
#ENV HYDROXIDEUSER you@youremail.here
#ENV HYDROXIDEPASS yourPasswordHere 

# copy hydroxide
COPY --from=builder /go/bin/hydroxide /usr/bin/hydroxide

COPY ./docker_shell_scripts/start.sh start.sh
COPY ./docker_shell_scripts/expect.sh expect.sh 
COPY ./docker_shell_scripts/hydroxide-auth-cli.sh /usr/local/bin/hydroxide-auth-cli
RUN chmod +x ./expect.sh /usr/local/bin/hydroxide-auth-cli
RUN apk add expect 

WORKDIR /

ENTRYPOINT ["/start.sh"] 
