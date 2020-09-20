FROM ubuntu:20.04
MAINTAINER Carles Amigó, fr3nd@fr3nd.net

ENV DELUGE_VERSION 2.0.3
#ENV DELUGE_VERSION 2.0.3-2

      #deluge-web=$DELUGE_VERSION \
      #deluge-console=$DELUGE_VERSION \
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      geoip-database \
      git \
      intltool \
      librsvg2-common \
      python3 \
      python3-chardet \
      python3-libtorrent \
      python3-mako \
      python3-openssl \
      python3-pip \
      python3-setuptools \
      python3-twisted \
      python3-xdg \
      supervisor \
      xdg-utils \
      && rm -rf /usr/share/doc/* && \
      rm -rf /usr/share/info/* && \
      rm -rf /tmp/* && \
      rm -rf /var/tmp/*

RUN mkdir -p /usr/src/deluge
WORKDIR /usr/src/deluge
RUN curl -L http://download.deluge-torrent.org/source/2.0/deluge-${DELUGE_VERSION}.tar.xz | \
    tar xvJ --strip-components=1 && \
    python3 setup.py build && \
    python3 setup.py install --install-layout=deb && \
    rm -rf /usr/src/deluge

ENV DELUGE_TELEGRAMER_REPO https://github.com/noam09/deluge-telegramer.git
ENV DELUGE_TELEGRAMER_VERSION v1.2

RUN mkdir -p /usr/src/deluge-telegramer
WORKDIR /usr/src/deluge-telegramer
RUN git clone ${DELUGE_TELEGRAMER_REPO} . && \
    git checkout ${DELUGE_TELEGRAMER_VERSION} && \
    pip install certifi==2018.8.24 && \
    python3 setup.py bdist_egg && \
    cp dist/Telegramer*.egg /usr/lib/python2.7/dist-packages/deluge-${DELUGE_VERSION}-py2.7.egg/deluge/plugins && \
    rm -rf /usr/src/deluge-telegramer

WORKDIR /

COPY supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 8112 58846 58946 58946/udp

CMD	/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
