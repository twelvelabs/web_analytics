## Overview

A simple web analytics prototype (Rails+React) I was asked to put together as a [programming exercise](./docs/requirements.md).

## Prerequisites

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/) (already installed w/ Docker for Mac)

## Install

```bash
# Clone the app
git clone git@github.com:twelvelabs/web_analytics.git
cd ./web_analytics
docker-compose build
# Setup the dev and test databases
# The AR version of `db:setup` does both, but `sequel-rails` does not :shrug:
docker-compose run --rm app rake db:setup
docker-compose run --rm -e "RAILS_ENV=test" app rake db:create
```

There are two rake tasks for setting up the dummy dataset:

```bash
# This will generate a 1M row CSV file in ./tmp and import it into the development database.
# First run takes a minute or so to write the CSV, but successive runs will re-use it and be faster.
rake dataset:import
# If for any reason you want to regen the CSV (i.e. when making changes to the generator logic):
rake dataset:regenerate
```

## Running

```bash
docker-compose up
open http://0.0.0.0:3000
```

The API endpoints are cached with a short 5m TTL, but Rails doesn't enable caching in the development environment by default. To enable:

```bash
docker-compose run --rm app rails dev:cache
```

## Tests

```bash
docker-compose run --rm app rails test
```

Note: the above runs tests in a new container each time (and thus doesn't take advantage of `spring`). It's much more efficient to start up a persistent shell process if you're repeatedly running tests:

```bash
docker-compose run --rm app sh
# inside the container
rails t path/to/some/test.rb
# code changes
rails t path/to/some/test.rb
# etc...
```
