FROM golang:1.22.1-alpine3.19

COPY ./main.go /app/
COPY ./go.mod /app/

WORKDIR /app/
RUN /usr/local/go/bin/go mod tidy
RUN /usr/local/go/bin/go build -o app

EXPOSE 9080
ENTRYPOINT ["/app/app"]