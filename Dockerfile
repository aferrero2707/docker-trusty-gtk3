FROM photoflow/docker-trusty-appimage-base:latest

RUN adduser --debug --system --group --home /var/lib/colord colord --quiet 

# Install system packages
RUN apt-get update && apt-get install -y software-properties-common \
intltool libpng12-dev make \
automake libfftw3-dev libjpeg-turbo8-dev \
libpng12-dev libwebp-dev libxml2-dev swig libmagick++-dev \
bc libcfitsio3-dev libgsl0-dev libmatio-dev liborc-0.4-dev \
libgif-dev libpugixml-dev wget git itstool \
bison flex ragel unzip libdbus-1-dev libxtst-dev \
mesa-common-dev libgl1-mesa-dev libegl1-mesa-dev valac \
libxml2-utils xsltproc docbook-xsl libffi-dev \
 libvorbis-dev python-six cargo curl
 
RUN mkdir -p /work/conf/modulesets
COPY *.patch /work/conf/

# Get auxiliary configuration files and compile base dependencies
# Fix python SSL support
RUN mkdir -p /work && cd /work && \
apt-get install -y libssl-dev && mkdir -p /work && cd /work && rm -rf Python-2.7.13* && wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz && tar xJvf Python-2.7.13.tar.xz && cd Python-2.7.13 && ./configure --prefix=/$AIPREFIX --enable-shared --enable-ipv6 --enable-loadable-sqlite-extensions --with-threads --enable-unicode=ucs2 && make -j 2 && make install && python -c "import ssl; print(ssl.OPENSSL_VERSION)"
RUN rm -rf Python-* && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz && tar xJvf Python-3.6.3.tar.xz && cd Python-3.6.3 && ./configure --prefix=/$AIPREFIX --enable-shared --enable-ipv6 --enable-loadable-sqlite-extensions --with-threads  --enable-unicode=ucs2 && make -j 2 install


#RUN mkdir -p /work && cd /work && \
#rm -rf Python-* && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz && tar xJvf Python-3.6.3.tar.xz && cd Python-3.6.3 && ./configure --prefix=/$AIPREFIX --enable-shared --enable-unicode=ucs2 && make -j 2 install
#(rm -rf Python-3.5.3* && wget https://www.python.org/ftp/python/3.5.3/Python-3.5.3.tar.xz && tar xJvf Python-3.5.3.tar.xz && cd Python-3.5.3 && ./configure --prefix=/${install_prefix} --enable-shared --enable-ipv6 --enable-loadable-sqlite-extensions --with-threads --without-ensurepip && make && make install)

RUN cd /work && rm -rf jhbuild && git clone https://github.com/GNOME/jhbuild.git && cd jhbuild && patch -p1 -i /work/conf/jhbuild-run-as-root.patch && ./autogen.sh --prefix=/work/inst && make -j 2 install && \
cd /work && rm -rf libepoxy* && wget https://github.com/anholt/libepoxy/releases/download/v1.3.1/libepoxy-1.3.1.tar.bz2 && tar xjvf libepoxy-1.3.1.tar.bz2 && cd libepoxy-1.3.1 && ./configure --prefix=/$AIPREFIX && make -j 2 && make install && \
cd /work && rm -rf lcms* && wget https://downloads.sourceforge.net/lcms/lcms2-2.8.tar.gz && tar xzvf lcms2-2.8.tar.gz && cd lcms2-2.8 && ./configure --prefix=/$AIPREFIX && make -j 2 && make install && \
cd /work && rm -f get-pip.py && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py && pip install six && \
cd / && curl https://sh.rustup.rs -sSf | sh -s -- -y

#RUN mkdir -p /work && cd /work && git clone https://github.com/rust-lang/rust.git && cd rust && ./x.py build && ./x.py install


ENV PATH=/root/.cargo/bin:$PATH
RUN which rustc

COPY jhbuildrc /work/conf/
COPY modulesets/* /work/conf/modulesets/

#RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps gettext libtiff
#RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps cairo at-spi2-atk
#RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib atkmm-1.6
#RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtk+-3
#RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib pangomm-1.4
#RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtkmm-3

RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps gettext libtiff cairo at-spi2-atk
RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib cairo at-spi2-atk atkmm-1.6 gtk+-3 pangomm-1.4 gtkmm-3

#cleanup
RUN rm -rf /gcc-* && cd /work && rm -rf checkout build gcc-* Python-* libepoxy* cmake* lcms2* libcanberra*

#RUN cd /work && rm -rf libcanberra* && wget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz && tar xJvf libcanberra-0.30.tar.xz && cd libcanberra-0.30 && ./configure --prefix=/$AIPREFIX --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 && make install && rm -rf libcanberra-0.30

COPY show_versions.sh /$AIPREFIX/bin
