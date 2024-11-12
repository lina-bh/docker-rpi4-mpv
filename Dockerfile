FROM ghcr.io/lina-bh/raspberry-pi-os-docker AS build

ARG mpv_build_ref=993fe7d4a07d0575662ed2563585734b7e58dccd
ARG libplacebo_ref=5788a82f459f617a999c4d56278d54d0edfc7b81
ARG mpv_ref=8873beabc3e22d0ef9b2e1fe4a5068bebf71bfa4

RUN apt-get update
RUN apt-get install --no-install-recommends -y ca-certificates curl

RUN curl --no-progress-meter --verbose --location https://github.com/mpv-player/mpv-build/archive/${mpv_build_ref}.tar.gz | tar -xzvC /
WORKDIR /mpv-build-${mpv_build_ref}

RUN curl --no-progress-meter -L https://code.videolan.org/videolan/libplacebo/-/archive/${libplacebo_ref}/libplacebo-${libplacebo_ref}.tar.gz | tar -xzv
RUN mv libplacebo-${libplacebo_ref} libplacebo

RUN curl --no-progress-meter --verbose --location https://github.com/mpv-player/mpv/archive/${mpv_ref}.tar.gz | tar -xzv
RUN mv mpv-${mpv_ref} mpv

ARG jobs=1
ENV CFLAGS="-mcpu=cortex-a72 -ftree-vectorize -O3 -pipe -fomit-frame-pointer"
COPY libplacebo_options .
RUN apt-get install -y --no-install-recommends meson
RUN ./scripts/libplacebo-config
RUN ./scripts/libplacebo-build -j${jobs}
