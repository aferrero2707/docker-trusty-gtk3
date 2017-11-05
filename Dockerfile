FROM ubuntu:14.04

RUN adduser --debug --system --group --home /var/lib/colord colord --quiet 

# Install system packages
RUN apt-get update && apt-get install -y software-properties-common \
gcc g++ intltool libpng12-dev make \
automake libfftw3-dev libjpeg-turbo8-dev \
libpng12-dev libwebp-dev libtiff4-dev libxml2-dev swig libmagick++-dev \
bc libcfitsio3-dev libgsl0-dev libmatio-dev liborc-0.4-dev \
libgif-dev libpugixml-dev wget git itstool \
bison flex ragel unzip libdbus-1-dev libxtst-dev \
cargo mesa-common-dev libgl1-mesa-dev libegl1-mesa-dev valac \
libxml2-utils xsltproc docbook-xsl libffi-dev \
 libvorbis-dev python-six

# Set environment variables
ENV PATH=/app/bin:/work/inst/bin:$PATH LD_LIBRARY_PATH=/app/lib:/work/inst/lib:$LD_LIBRARY_PATH PKG_CONFIG_PATH=/app/lib/pkgconfig:/work/inst/lib/pkgconfig:$PKG_CONFIG_PATH

# Get auxiliary configuration files and compile base dependencies
RUN mkdir -p /work && cd /work && git clone https://github.com/aferrero2707/docker-trusty-gtk3 -b master conf && \
cd /work && rm -rf Python-* && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz && tar xJvf Python-3.6.3.tar.xz && cd Python-3.6.3 && ./configure --prefix=/app --enable-shared --enable-unicode=ucs2 && make -j 2 install
RUN cd /work && rm -rf jhbuild && git clone https://github.com/GNOME/jhbuild.git && cd jhbuild && patch -p1 -i /work/conf/jhbuild-run-as-root.patch && ./autogen.sh --prefix=/work/inst && make -j 2 install && \
cd /work && rm -rf libepoxy* && wget https://github.com/anholt/libepoxy/releases/download/v1.3.1/libepoxy-1.3.1.tar.bz2 && tar xjvf libepoxy-1.3.1.tar.bz2 && cd libepoxy-1.3.1 && ./configure --prefix=/app && make -j 2 && make install && \
cd /work && rm -rf cmake* && wget https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz && tar xzvf cmake-3.8.2.tar.gz && cd cmake-3.8.2 && ./bootstrap --prefix=/work/inst --parallel=2 && make -j 2 && make install && \
cd /work && rm -rf lcms* && wget https://downloads.sourceforge.net/lcms/lcms2-2.8.tar.gz && tar xzvf lcms2-2.8.tar.gz && cd lcms2-2.8 && ./configure --prefix=/app && make -j 2 && make install

#cd /work && rm -f ninja* && wget https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-linux.zip && unzip ninja-linux.zip && cp -a ninja /work/inst/bin

RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps gettext tiff && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps cairo at-spi2-atk && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib atkmm-1.6 && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtk+-3 && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib pangomm-1.4 && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtkmm-3 && \
rm -rf /work/checkout && rm -rf /work/build

RUN cd /work && rm -rf libcanberra* && wget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz && tar xJvf libcanberra-0.30.tar.xz && cd libcanberra-0.30 && ./configure --prefix=/app --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 && make install && rm -rf libcanberra-0.30
