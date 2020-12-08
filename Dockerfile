ARG FLUENTD_VERSION
FROM fluent/fluentd:${FLUENTD_VERSION}
USER root
WORKDIR /home/fluent
ENV PATH /fluentd/vendor/bundle/ruby/2.6.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.6.0
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.6.0
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1
COPY Gemfile Gemfile.lock /fluentd/
RUN buildDeps="sudo make gcc g++ libc-dev libffi-dev ca-certificates libjemalloc1 libzmq5-dev" \
     && apt-get update \
     && apt-get upgrade -y \
     && apt-get install \
     -y --no-install-recommends \
     $buildDeps net-tools \
    && gem install bundler --version 1.16.2 \
    && bundle config silence_root_warning true \
    && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
    && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
RUN touch /fluentd/etc/disable.conf
COPY plugins /fluentd/plugins/
COPY entrypoint.sh /fluentd/entrypoint.sh
ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"
ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]
