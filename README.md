## Overview

A simple web analytics prototype (Rails+React) I was asked to put together as a [programming exercise](./docs/requirements.md).

## Prerequisites

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/) (already installed w/ Docker for Mac)

## Install

```
git clone git@github.com:twelvelabs/web_analytics.git
cd ./web_analytics
docker-compose build
```

## Running

```
docker-compose up
```

## Tests

```
docker-compose run --rm app rails test
```

