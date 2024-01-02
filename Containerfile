FROM quay.io/toolbx-images/ubuntu-toolbox:22.04

ARG ZEPHYR_SDK_VERSION=0.16.4
ARG ZEPHYR_SDK_TOOLCHAIN="arm-zephyr-eabi"
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk/${ZEPHYR_SDK_VERSION}

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="An image for developing Zephyr RTOS applications" \
      maintainer="brett@witherspoon.engineering"

COPY extra-packages /
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends $(cat extra-packages | xargs) \
    && rm -rd /var/lib/apt/lists/*
RUN rm /extra-packages

RUN sdk_file_name="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m)_minimal.tar.xz" \
    && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${sdk_file_name}" \
    && mkdir -p ${ZEPHYR_SDK_INSTALL_DIR} \
    && tar -xvf ${sdk_file_name} -C ${ZEPHYR_SDK_INSTALL_DIR} --strip-components=1 \
    && ${ZEPHYR_SDK_INSTALL_DIR}/setup.sh -h -c -t ${ZEPHYR_SDK_TOOLCHAIN} \
    && rm ${sdk_file_name} ${ZEPHYR_SDK_INSTALL_DIR}/zephyr-sdk-$(uname -m)-hosttools-standalone-0.9.sh

ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV

ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir west
