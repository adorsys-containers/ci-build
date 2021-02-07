RUN curl -sSf -L http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official -o /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial \
    && echo -e '[nodejs]\nname=nodejs\nstream=\nprofiles=\nstate=disabled' > /etc/dnf/modules.d/nodejs.module \
    && echo -e '[centos-8-baseos]\nname=CentOS-$releasever - BaseOS\nbaseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial' > /etc/yum.repos.d/centos-8-baseos.repo \
    && echo -e '[centos-8-appstream]\nname=CentOS-$releasever - AppStream\nbaseurl=http://mirror.centos.org/centos/$releasever/AppStream/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial' > /etc/yum.repos.d/centos-8-appstream.repo \
    && echo -e '[nodesource]\nname=nodesource\nbaseurl=https://rpm.nodesource.com/pub_14.x/el/8/$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.nodesource.com/pub/el/NODESOURCE-GPG-SIGNING-KEY-EL' > /etc/yum.repos.d/nodesource.repo \
    && microdnf --noplugins install --nodocs -y --enablerepo=nodesource \
        --enablerepo=centos-8-baseos --enablerepo=centos-8-appstream \
        --enablerepo=copr:copr.fedorainfracloud.org:jkroepke:git \
      gcc-c++ make nodejs \
      # Chrome / Firefox
      libX11 libX11-xcb libXcomposite libXcursor libXdamage libXext libXi libXtst nss cups-libs libXScrnSaver libdrm \
      libXrandr mesa-libgbm alsa-lib atk at-spi2-atk pango gtk3 dbus-glib libXt \
    && npm install -g npm@6 yarn \
    && npm cache clear --force \
    && microdnf --noplugins clean all -y && rm -rf /var/cache/yum
