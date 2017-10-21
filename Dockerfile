FROM photoflow/docker-trusty-gtk3-step1:latest

RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps cairo at-spi2-atk
RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib atkmm-1.6
RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtk+-3
RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib pangomm-1.4
RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtkmm-3
