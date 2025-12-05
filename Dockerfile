ARG SCHEME=chibi
ARG IMAGE=${SCHEME}:head
FROM debian:trixie AS build
RUN apt-get update && apt-get install -y git ca-certificates
WORKDIR /build
RUN git clone https://codeberg.org/retropikzel/compile-scheme.git --depth=1

ARG SCHEME=chibi
ARG IMAGE=${SCHEME}:head
FROM schemers/${IMAGE}
RUN apt-get update && apt-get install -y make gauche
COPY --from=build /build /build
WORKDIR /build/compile-scheme
RUN make build-gauche && make install
WORKDIR /workdir
ARG SCHEME=chibi
ENV COMPILE_R7RS=${SCHEME}
COPY Makefile .
COPY preludes preludes/
COPY input input/
COPY coverage .
