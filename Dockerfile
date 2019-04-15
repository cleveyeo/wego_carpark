FROM ruby:2.6
RUN apt-get update -qq && apt-get install -y nodejs tzdata mysql-client
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp