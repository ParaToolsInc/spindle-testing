# This is based on the Flux Container Tutorial
# See https://flux-framework.readthedocs.io/en/latest/tutorials/containers
ARG flux_sched_version=jammy
FROM fluxrm/flux-sched:${flux_sched_version} AS builder
ARG replicas=3
ENV workers=${replicas}
USER root

RUN DEBIAN_FRONTEND="noninteractive" apt-get update \
    && apt-get -qq install -y --no-install-recommends \
        autotools-dev \
        autoconf \
        automake \
        cmake \
        git \
        python3 \
        openssh-server \
        openssh-client \
        libdb-dev \
        apt-utils \
        dnsutils \
        iputils-ping \
        python3-pip \
        libgcrypt20 \
        libgcrypt20-dev \
        gdb \
        software-properties-common

ARG USER=fluxuser
ARG BUILD_ROOT=./containers/spindle-flux-ubuntu

# Allow fluxuser to run as other users so it can start munged
RUN sh -c "printf \"$USER ALL=(ALL) NOPASSWD: ALL\\n\" >> /etc/sudoers"

# Configure flux
ENV STATE_DIR=/var/lib/flux
RUN mkdir -p ${STATE_DIR} /etc/flux/system /etc/flux/system/cron.d /etc/flux/config /run/flux /etc/flux/imp/conf.d
COPY $BUILD_ROOT/flux/imp.toml /etc/flux/imp/conf.d/
COPY $BUILD_ROOT/flux/broker.toml /etc/flux/config/
RUN mkdir -p /etc/flux/system/cron.d && \
    mkdir -p /mnt/curve && \
    flux keygen /mnt/curve/curve.cert && \
    flux R encode --hosts="node-[1-${workers}]" > /etc/flux/system/R && \
    chown -R $USER:$USER /run/flux ${STATE_DIR} /mnt/curve/curve.cert ${workdir}

# Build Spindle
WORKDIR /home/$USER
COPY . /home/$USER/Spindle
COPY $BUILD_ROOT/scripts/build_spindle.sh /home/$USER/build_spindle.sh
RUN ./build_spindle.sh

RUN chown -R $USER:$USER /home/fluxuser && \
    chown -R $USER:$USER /run/flux && \
    mkdir -p /shared && \
    chown -R $USER:$USER /shared && \
    mkdir -p /code/workdir && \
    chown -R $USER:$USER /code/workdir

USER $USER
COPY $BUILD_ROOT/scripts/flux_healthcheck.sh ./
COPY $BUILD_ROOT/scripts/run_spindle_tests.sh ./
COPY $BUILD_ROOT/scripts/entrypoint.sh ./
ENV PATH /home/$USER/Spindle-inst/bin:$PATH
ENV HWLOC_HIDE_ERRORS 2
ENV RDMAV_FORK_SAFE 1
ENTRYPOINT /bin/bash ./entrypoint.sh
