# ----- BUILD STAGE
FROM elixir:alpine AS app_builder

# Set env vars for build
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8

RUN apk add --update git && \
    rm -rf /var/cache/apk/*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create build dir
RUN mkdir /app
WORKDIR /app

# Copy config
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Fetch deps
RUN mix deps.get
RUN mix deps.compile
RUN mix phx.digest
RUN mix release

# ----- APP STAGE
FROM alpine AS app

ENV LANG=C.UTF-8

# Install openssl
RUN apk add --update openssl ncurses-libs && rm -rf /var/cache/apk/*

# Copy build artifacts from builder
RUN adduser -D -h /home/app app
WORKDIR /home/app
COPY --from=app_builder /app/_build .
RUN chown -R app: ./prod
USER app

COPY entrypoint.sh .

# Run
ENTRYPOINT ["./entrypoint.sh"]
