FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y python3 python3-pip curl git sudo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/taku910/mecab.git
WORKDIR /opt/mecab/mecab
RUN ./configure  --enable-utf8-only \
  && make \
  && make check \
  && make install \
  && ldconfig

WORKDIR /opt/mecab/mecab-ipadic
RUN ./configure --with-charset=utf8 \
  && make \
  && make install

WORKDIR /opt
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
WORKDIR /opt/mecab-ipadic-neologd
RUN ./bin/install-mecab-ipadic-neologd -n -y

RUN pip3 install -U pip mecab-python3

WORKDIR /opt/opencv
RUN pip3 install -U numpy
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y build-essential cmake pkg-config unzip \
                       libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
                       libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
                       libxvidcore-dev libx264-dev \
                       libgtk-3-dev libatlas-base-dev gfortran
RUN pip3 install opencv-python