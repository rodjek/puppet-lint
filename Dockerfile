FROM alpine:3.10

RUN apk add --no-cache ruby=2.5.7-r0 ruby-json=2.5.7-r0 && \
    mkdir /puppet-lint /puppet

VOLUME /puppet
WORKDIR /puppet
ENTRYPOINT ["/puppet-lint/bin/puppet-lint"]
CMD ["--help"]

COPY . /puppet-lint/
