FROM debian:wheezy
MAINTAINER Shane Starcher <shanestarcher@gmail.com>

RUN apt-get update && apt-get install -y wget ca-certificates && apt-get -y clean
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
RUN echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

RUN apt-get update && \
    apt-get install -y sensu && \
    apt-get -y clean

RUN apt-get install build-essential -y

ADD templates /etc/sensu/templates

ENV PATH /opt/sensu/embedded/bin:$PATH

RUN wget https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.0.2.tar.gz

ADD bin /bin/

RUN gem install bundler -v 1.9.9 --no-document
ENV PLUGINS hipchat mailer pagerduty
ENV PLUGINS_REPO sensu-plugins
RUN /bin/install

EXPOSE 4567
VOLUME ["/etc/sensu/conf.d"]

ENV LOG_LEVEL warn
ENV EMBEDDED_RUBY true
ENV CONFIG_FILE /etc/sensu/config.json
ENV CONFIG_DIR /etc/sensu/conf.d
ENV EXTENSION_DIR /etc/sensu/extensions
ENV PLUGINS_DIR /etc/sensu/plugins
ENV HANDLERS_DIR /etc/sensu/handlers
ENV DEPENDENCIES redis rabbitmq



CMD /bin/start
