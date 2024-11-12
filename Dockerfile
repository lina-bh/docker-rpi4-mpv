FROM ghcr.io/lina-bh/raspberry-pi-os-docker AS build

ARG mpv_build_ref=993fe7d4a07d0575662ed2563585734b7e58dccd
ARG libplacebo_ref=5788a82f459f617a999c4d56278d54d0edfc7b81
ARG mpv_ref=8873beabc3e22d0ef9b2e1fe4a5068bebf71bfa4
ARG jobs=1
ENV CFLAGS="-mcpu=cortex-a72 -ftree-vectorize -O3 -pipe -fomit-frame-pointer"

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates curl g++ glslang-dev libasound2-dev libass-dev libavfilter-dev libdrm-dev libegl-dev liblcms2-dev liblua5.1-0-dev libvulkan-dev meson pkgconf python3-jinja2 deborphan

RUN ["bash", "-c", "set -o pipefail && curl --no-progress-meter -L https://github.com/mpv-player/mpv-build/archive/${mpv_build_ref}/${mpv_build_ref}.tar.gz | tar -xvzC / && mv mpv-build-${mpv_build_ref} mpv-build"]
WORKDIR /mpv-build

RUN ["bash", "-c", "set -o pipefail && curl --no-progress-meter -L https://github.com/mpv-player/mpv/archive/${mpv_ref}/${mpv_ref}.tar.gz | tar -xzv && mv mpv-${mpv_ref} mpv"]

RUN ["bash", "-c", "set -o pipefail && curl --no-progress-meter -L https://code.videolan.org/videolan/libplacebo/-/archive/${libplacebo_ref}/libplacebo-${libplacebo_ref}.tar.gz | tar -xzv && mv libplacebo-${libplacebo_ref} libplacebo"]

COPY libplacebo_options .
RUN ./scripts/libplacebo-config
RUN ./scripts/libplacebo-build -j${jobs}
COPY mpv_options .
RUN ./scripts/mpv-config
RUN ./scripts/mpv-build -j${jobs}
RUN ./scripts/mpv-install

FROM ghcr.io/lina-bh/raspberry-pi-os-docker

RUN apt-get update && apt-get install -y --no-install-recommends libavfilter8 libegl1 liblua5.1-0

COPY --from=build /usr/local/bin/mpv /usr/local/bin/mpv

CMD /usr/local/bin/mpv
