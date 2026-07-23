# build
FROM ocaml/opam:debian-12-ocaml-5.2 AS builder
RUN sudo apt-get update && sudo apt-get install -y \
    libev-dev libssl-dev libgmp-dev pkg-config
WORKDIR /home/opam/app
COPY --chown=opam obscurity.opam dune-project ./
RUN opam install . --deps-only
COPY --chown=opam . .
RUN opam exec -- dune build --profile release

# run
FROM debian:12-slim
RUN apt-get update && apt-get install -y \
    libev4 libssl3 libgmp10 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /home/opam/app/_build/default/bin/main.exe ./obscurity
COPY data ./data
EXPOSE 8080
CMD ["./obscurity"]
