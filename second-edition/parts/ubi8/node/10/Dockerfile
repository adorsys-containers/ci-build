RUN \
    && echo -e '[centos-8-baseos]\nname=CentOS-$releasever - BaseOS\nbaseurl=http://mirror.centos.org/centos/$releasever/BaseOS/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=https://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official' > /etc/yum.repos.d/centos-8-baseos.repo \
    && echo -e '[centos-8-appstream]\nname=CentOS-$releasever - AppStream\nbaseurl=http://mirror.centos.org/centos/$releasever/AppStream/$basearch/os/\ngpgcheck=1\npriority=99\nenabled=0\ngpgkey=https://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-Official' > /etc/yum.repos.d/centos-8-appstream.repo \
    && echo -e '[nodesource]\nname=nodesource\nbaseurl=https://rpm.nodesource.com/pub_10.x/el/8/$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.nodesource.com/pub/el/NODESOURCE-GPG-SIGNING-KEY-EL' > /etc/yum.repos.d/nodesource.repo \
    && microdnf install --nodocs -y --enablerepo=docker-ce-stable \
        --enablerepo=centos-8-baseos --enablerepo=centos-8-appstream \
        --enablerepo=copr:copr.fedorainfracloud.org:jkroepke:git \
      gcc-c++ make nodejs \
    && npm install -g npm yarn
    && npm cache clear --force \
    && microdnf clean all -y && rm -rf /var/cache/yum
