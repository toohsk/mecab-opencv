FROM python:3.6-alpine

MAINTAINER toohsk <toohsk@gmail.com>

# RUN apk update && apk upgrade
# RUN apk add --update git bash wget tar gcc g++ make alpine-sdk

# # Download MeCab
# RUN wget -O /tmp/mecab-0.996.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE"
# RUN tar -zxvf /tmp/mecab-0.996.tar.gz -C /tmp

# # Build MeCab
# RUN cd /tmp/mecab-0.996 && \
#     ./configure && \
#     make && make check && make install
# RUN cd / && \
#     rm -rf /tmp/mecab-0.996 && \
#     rm /tmp/mecab-0.996.tar.gz

# # Intall neologd for dictionary
# ENV LIB_DIR /usr/lib/mecab/dic
# RUN mkdir -p "$LIB_DIR"
# RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git /tmp/neologd && \
#   /tmp/neologd/bin/install-mecab-ipadic-neologd -n -u -y && \
#   rm -rf /tmp/neologd

# # Add python-mecab 
# RUN pip install -U mecab-python3

# # Clean apk cache
# RUN rm -rf /var/cache/apk/*

RUN apk add --update --no-cache build-base

ENV MECAB_VERSION 0.996
ENV mecab_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE
ENV build_deps 'curl git bash file sudo openssh'
ENV dependencies 'openssl'

# Install MeCab-Neologd
RUN apk add --update --no-cache ${build_deps} \
  # Install dependencies
  && apk add --update --no-cache ${dependencies} \
  # Install MeCab
  && curl -SL -o mecab-${MECAB_VERSION}.tar.gz ${mecab_url} \
  && tar zxf mecab-${MECAB_VERSION}.tar.gz \
  && cd mecab-${MECAB_VERSION} \
  && ./configure --enable-utf8-only --with-charset=utf8 \
  && make \
  && make install \
  && cd \
  # Install Neologd
  && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
  && mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y \
  # Clean up
  && apk del ${build_deps} \
  && rm -rf \
    mecab-${MECAB_VERSION}* \
    mecab-${IPADIC_VERSION}* \
    mecab-ipadic-neologd

# Install Opencv
ENV SRC_DIR=/tmp
ENV CC=/usr/bin/clang CXX=/usr/bin/clang++

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && apk update \

    # install build dependencies
    && apk add --no-cache --virtual .build-deps \
        build-base \
        cmake \
        git \
        wget \
        unzip \

    # install opencv dependencies
    && apk add --no-cache \
        clang \
        clang-dev \
        jasper-dev \
        libavc1394-dev  \
        libdc1394-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libtbb \
        libtbb-dev \
        libwebp-dev \
        linux-headers \
        openblas-dev \
        tiff-dev \

    # fix for numpy compilation
    && ln -s /usr/include/locale.h /usr/include/xlocale.h \

    # install numpy
    && pip install \
        numpy==1.12.0 \

    # download opencv source
    && mkdir -p ${SRC_DIR} \
    && cd ${SRC_DIR} \
    && wget https://github.com/opencv/opencv/archive/3.2.0.zip \
    && unzip 3.2.0.zip \
    && mv opencv-3.2.0 opencv \
    && rm 3.2.0.zip \

    # download opnecv_contrib source
    && wget https://github.com/opencv/opencv_contrib/archive/3.2.0.zip \
    && unzip 3.2.0.zip \
    && mv opencv_contrib-3.2.0 opencv_contrib \
    && rm 3.2.0.zip \

    # build
    && mkdir -p ${SRC_DIR}/opencv/build \
    && cd ${SRC_DIR}/opencv/build \
    && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/ -D BUILD_DOCS=OFF .. \
    && make -j3 \
    && make install \
    && rm -rf ${SRC_DIR} \
    && ln /dev/null /dev/raw1394 \
    && apk del --purge .build-deps
