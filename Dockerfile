FROM ruby:3.3-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential git \
 && rm -rf /var/lib/apt/lists/*

# gems baked into the image, outside the /site mount
WORKDIR /gems
COPY Gemfile Gemfile.lock ./

ENV BUNDLE_GEMFILE=/gems/Gemfile \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_FROZEN=true \
    JEKYLL_ENV=production

RUN bundle install && chmod -R a+rX /usr/local/bundle

WORKDIR /site
ENTRYPOINT ["bundle", "exec", "jekyll"]
CMD ["build"]
