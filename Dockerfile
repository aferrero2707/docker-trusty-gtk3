FROM ubuntu:14.04

RUN apt-get update && apt-get install -y software-properties-common
RUN sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test && apt-get -y update

#RUN adduser --debug --system --group --home /var/lib/colord colord \
#	    --quiet --gecos "colord colour management daemon"
RUN adduser --debug --system --group --home /var/lib/colord colord --quiet 

RUN apt-get install -y gcc-5 g++-5 gettext intltool \
gir1.2-gtk-3.0 libgtk2.0-dev \
liblcms2-dev \
libpng12-dev \
python-dev python-gi-dev python-gi-cairo python-nose python-numpy \
automake gtk-doc-tools gobject-introspection libfftw3-dev libjpeg-turbo8-dev \
libpng12-dev libwebp-dev libtiff4-dev libxml2-dev swig libmagick++-dev \
bc libcfitsio3-dev libgsl0-dev libmatio-dev liborc-0.4-dev libpoppler-glib-dev \
librsvg2-dev libgif-dev python-dev libsigc++-2.0-dev libpixman-1-dev \
libpango1.0-dev libpangoft2-1.0-0 libglib2.0-dev libglibmm-2.4-dev \
libgtkmm-2.4-dev libpugixml-dev gtk2-engines-pixbuf wget git itstool \
bison flex ragel unzip libdbus-1-dev libxtst-dev \
cargo mesa-common-dev libgl1-mesa-dev valac libepoxy-dev && \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5

ENV PATH=/work/inst/bin:/work/inst/bin:$PATH LD_LIBRARY_PATH=/app/lib:/work/inst/lib:$LD_LIBRARY_PATH

RUN mkdir -p /work/modulesets
ADD jhbuild-run-as-root.patch /work
ADD jhbuildrc /work
ADD modulesets /work/modulesets

RUN cd /work && rm -rf Python-* && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz && tar xJvf Python-3.6.3.tar.xz && cd Python-3.6.3 && ./configure --prefix=/work/inst --enable-shared --enable-unicode=ucs2 && make -j 2 install && \
cd /work && rm -rf jhbuild && git clone https://github.com/GNOME/jhbuild.git && cd jhbuild && patch -p1 -i /work/jhbuild-run-as-root.patch && ./autogen.sh --prefix=/work/inst && make install
#cd /work && rm -f ninja* && wget https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-linux.zip && unzip ninja-linux.zip && cp -a ninja /work/inst/bin

RUN jhbuild --conditions=-wayland -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps gettext
RUN jhbuild --conditions=-wayland -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps cairo at-spi2-atk
RUN jhbuild --conditions=-wayland -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib atkmm-1.6
RUN jhbuild --conditions=-wayland -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtkmm-3

#RUN jhbuild -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib cairo
#RUN jhbuild -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib glibmm-2.4
#RUN jhbuild -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gobject-introspection
#RUN jhbuild -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gdk-pixbuf
#RUN jhbuild -f "/work/jhbuildrc" -m "/work/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib pango
