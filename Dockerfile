# Development Dockerfile for the Lumelogics assessment API.
# Source is bind-mounted from the host in docker-compose, so changes hot-reload
# without rebuilds. For production deploys see Dockerfile.production (the
# multi-stage one Rails generated for Kamal).

FROM ruby:3.2-slim

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_LOG_TO_STDOUT=1

# System deps: libpq for the pg gem, build tools for native extensions,
# git for git-source gems, curl + postgresql-client for entrypoint waits + admin.
# ffmpeg + yt-dlp are required by the outreel AttachVideoJob (Loom → MP4/GIF).
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      git \
      curl \
      postgresql-client \
      ffmpeg \
      python3 \
      python3-pip \
  && pip3 install --break-system-packages --no-cache-dir yt-dlp \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /app

# Pre-install gems for layer caching. Compose bind-mounts the rest at runtime.
COPY Gemfile Gemfile.lock* ./
RUN gem install bundler -v '~> 2.5' --no-document \
  && bundle install

COPY . .

EXPOSE 3000

# Compose overrides this for the worker; default = web.
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
