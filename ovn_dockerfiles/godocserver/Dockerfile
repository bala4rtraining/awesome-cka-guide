FROM ovn-docker.artifactory.trusted.visa.com/godoc_base:0605
RUN ln -snf /usr/local/go/1.12* /usr/local/go/default
RUN mkdir -p /go/src/visa.com/
ADD ./overlay /go/src/visa.com/
ADD ./overlay/project.html /go/doc/
ENV GOPATH=/go
RUN mkdir /go/bin/ && cd /go/bin/ && go build -o godocserver /go/src/visa.com/main.go
RUN cd /go/src/visa.com/ 
ENTRYPOINT /go/bin/godocserver