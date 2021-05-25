FROM elixir:1.11-alpine AS compiler

ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

WORKDIR /srv/app

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get \
    && mix deps.compile \
    && mix compile

RUN mix release

FROM alpine:latest

ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

ENV APP_ENV="dev"

ARG APP_NAME=symbiosis
ENV APP_NAME=${APP_NAME}

ARG APP_RELEASE=development
ENV APP_RELEASE=${APP_RELEASE}


ENV RELEASE_TMP /tmp/

WORKDIR /srv/app

COPY \
    --from=compiler \
    --chown=nobody:nobody \
    /srv/app/_build/${MIX_ENV}/rel/symbiosis/ .

RUN chmod a+x /srv/app/bin/symbiosis

RUN apk add --no-cache --update \
    bash \
    ca-certificates

RUN update-ca-certificates --fresh

USER nobody

CMD ["/srv/app/bin/symbiosis", "start"]
