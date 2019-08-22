FROM ruby:2.6.3-alpine

ENV BOT_HOME /bot

RUN mkdir $BOT_HOME
WORKDIR $BOT_HOME

RUN apk update -qq &&\
    apk add --no-cache build-base libxml2-dev libxslt-dev postgresql-dev

ADD Gemfile .
ADD Gemfile.lock .
ADD .bundle .
RUN bundle install

ADD . .

CMD ["/usr/bin/env", "ruby", "./bin/run"]
