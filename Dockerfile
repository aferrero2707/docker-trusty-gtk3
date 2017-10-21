FROM photoflow/docker-trusty-gtk3-step2:latest

RUN jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib pangomm-1.4 && \
jhbuild --conditions=-wayland -f "/work/conf/jhbuildrc" -m "/work/conf/modulesets/gnome-suites-core-3.28.modules" build --nodeps --skip=glib gtkmm-3 && \
rm -rf /work/checkout && rm -rf /work/build
