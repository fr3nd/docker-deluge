FROM debian:jessie
MAINTAINER Carles Amigó, fr3nd@fr3nd.net

ENV DELUGE_VERSION 1.3.15

RUN apt-get update && apt-get install -y \
      build-essential \
      geoip-database \
      git \
      intltool \
      librsvg2-common \
      python \
      python-chardet \
      python-glade2 \
      python-libtorrent \
      python-mako \
      python-notify \
      python-openssl \
      python-pip \
      python-pygame \
      python-setuptools \
      python-twisted \
      python-xdg \
      supervisor \
      xdg-utils \
      && rm -rf /usr/share/doc/* && \
      rm -rf /usr/share/info/* && \
      rm -rf /tmp/* && \
      rm -rf /var/tmp/*

RUN mkdir -p /usr/src/deluge
WORKDIR /usr/src/deluge
RUN curl -L http://download.deluge-torrent.org/source/deluge-${DELUGE_VERSION}.tar.xz | \
    tar xvJ --strip-components=1 && \
    python setup.py build && \
    python setup.py install --install-layout=deb && \
    rm -rf /usr/src/deluge

ENV DELUGE_TELEGRAMER_REPO https://github.com/noam09/deluge-telegramer.git
ENV DELUGE_TELEGRAMER_VERSION 46ed53b2979ff84f54f557689f13fdef8330d2ce
RUN mkdir -p /usr/src/deluge-telegramer
WORKDIR /usr/src/deluge-telegramer
RUN git clone ${DELUGE_TELEGRAMER_REPO} . && \
    git checkout ${DELUGE_TELEGRAMER_VERSION} && \
    pip install certifi==2018.8.24 && \
    python setup.py bdist_egg && \
    cp dist/Telegramer*.egg /usr/lib/python2.7/dist-packages/deluge-${DELUGE_VERSION}-py2.7.egg/deluge/plugins && \
    rm -rf /usr/src/deluge-telegramer

WORKDIR /

COPY supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 8112 58846 58946 58946/udp

CMD	/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
