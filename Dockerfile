FROM ruby:2.7-alpine

RUN mkdir /puppet-lint /puppet

VOLUME /puppet
WORKDIR /puppet
ENTRYPOINT ["/puppet-lint/bin/puppet-lint"]
CMD ["--help"]

COPY . /puppet-lint/
