FROM photoflow/docker-trusty-gtk3-step1:latest

RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps cairo at-spi2-atk && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib atkmm-1.6 && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtk+-3
