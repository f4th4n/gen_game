FROM elixir:1.17.2

# Update default packages
RUN apt-get update

# Get Ubuntu packages
RUN apt-get install -y \
    build-essential \
    curl

# Update new packages
RUN apt-get update

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN mix local.hex --force && mix local.rebar --force

EXPOSE 4000

##########################################

WORKDIR /app
COPY . /app

RUN mix release

CMD [ "./entrypoint.sh" ]
