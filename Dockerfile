FROM ruby:2.3-alpine
MAINTAINER Shane Starcher <shanestarcher@gmail.com>

ENV SENSU_VERSION=0.25.5
ENV NOKOGIRI_DEPS libxml2-dev libxslt-dev 
ENV BUILD_DEPS git
ENV RUNTIME_DEPS bash build-base
# install sensu-core and ruby plugins
RUN apk add --no-cache $BUILD_DEPS $NOKOGIRI_DEPS $RUNTIME_DEPS \
    && gem install sensu -v ${SENSU_VERSION} \
    && gem install nokogiri \
    && gem install yaml2json \
    && apk del $BUILD_DEPS && rm -rf /var/cache/apk/*

ENV ENVTPL_VERSION=0.2.3
RUN \
    curl -Ls https://github.com/arschles/envtpl/releases/download/${ENVTPL_VERSION}/envtpl_linux_amd64 > /usr/local/bin/envtpl &&\
    chmod +x /usr/local/bin/envtpl

COPY templates /etc/sensu/templates
COPY bin /bin/

ENV DEFAULT_PLUGINS_REPO=sensu-plugins \
    DEFAULT_PLUGINS_VERSION=master \
    
    #Client Config
    CLIENT_SUBSCRIPTIONS=all,default \
    CLIENT_BIND=127.0.0.0 \
    CLIENT_DEREGISTER=true \

    #Common Config 
    RUNTIME_INSTALL='' \
    LOG_LEVEL=warn \
    CONFIG_FILE=/etc/sensu/config.json \
    CONFIG_DIR=/etc/sensu/conf.d \
    CHECK_DIR=/etc/sensu/check.d \
    EXTENSION_DIR=/etc/sensu/extensions \
    PLUGINS_DIR=/etc/sensu/plugins \
    HANDLERS_DIR=/etc/sensu/handlers \

    #Config for gathering host metrics
    HOST_DEV_DIR=/dev \
    HOST_PROC_DIR=/proc \
    HOST_SYS_DIR=/sys

RUN mkdir -p $CONFIG_DIR $CHECK_DIR $EXTENSION_DIR $PLUGINS_DIR $HANDLERS_DIR
RUN /bin/install http

EXPOSE 4567
VOLUME ["/etc/sensu/conf.d"]

ENTRYPOINT ["/bin/start"]
