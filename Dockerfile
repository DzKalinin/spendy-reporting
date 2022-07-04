FROM ruby:3.1.2

# install rails dependencies
#RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# create a folder /spendy-reporting in the docker container and go into that folder
RUN mkdir /spendy-reporting
WORKDIR /spendy-reporting

# Copy the Gemfile and Gemfile.lock from app root directory into the /spendy-reporting/ folder in the docker container
COPY Gemfile /spendy-reporting/Gemfile
COPY Gemfile.lock /spendy-reporting/Gemfile.lock

ADD config/application.yml.sample /spendy-reporting/config/application.yml
ADD config/google_key.json.sample /spendy-reporting/config/google_key.json

# Run bundle install to install gems inside the gemfile
RUN bundle install

# Copy the whole app
COPY . /spendy-reporting

EXPOSE 80
EXPOSE 8080

CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb", "-p", "8080"]
