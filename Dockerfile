FROM elixir:1.6.1

RUN apt-get -qq update
RUN apt-get -qq install git build-essential
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# now brunch
RUN npm install -g brunch

RUN mix local.hex --force && mix local.rebar --force && mix hex.info

WORKDIR /app
ENV MIX_ENV prod
ADD . .
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

RUN brunch build apps/planepals_web/assets --production

RUN mix phx.digest

ENV PORT=4001
CMD ["mix", "phx.server"]
