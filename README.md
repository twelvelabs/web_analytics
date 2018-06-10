## Overview

A simple web analytics prototype (Rails+React) I was asked to put together as a [programming exercise](./docs/requirements.md). I recorded my thoughts and design decisions in a short [retrospective](./docs/retrospective.md).

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

## Load testing

```bash
# I was going to sort out a docker solution for this, but ran out of time/patience (yay, abstractions)
brew install siege

cd $RAILS_ROOT
# -c50: 50 concurrent users
# -d10: random pause between 0-10s between requests
# -t3M: test for 3 minutes
# -i -f: randomly select URLs from this file
siege -c50 -d10 -t3M -i -f ./test/siege.txt

# Results (on a 2011-era MBP w/ SSD)

Lifting the server siege...
Transactions:		        1785 hits
Availability:		      100.00 %
Elapsed time:		      179.55 secs
Data transferred:	       27.31 MB
Response time:		        0.04 secs
Transaction rate:	        9.94 trans/sec
Throughput:		        0.15 MB/sec
Concurrency:		        0.41
Successful transactions:        1785
Failed transactions:	           0
Longest transaction:	        0.92
Shortest transaction:	        0.01
```
