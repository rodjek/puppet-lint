FROM ruby:latest as builder
WORKDIR /puppet-lint
COPY ./ ./
RUN bundle install --without development system_tests
RUN bundle exec rake test && \
  gem build puppet-lint.gemspec

FROM ruby:alpine
WORKDIR /puppet-lint
COPY --from=builder /puppet-lint/puppet-lint-*.gem .
RUN gem install puppet-lint-*.gem && \
  rm puppet-lint-*.gem
ENTRYPOINT ["/usr/bin/env", "puppet-lint"]
CMD ["-h"]
