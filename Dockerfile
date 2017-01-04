FROM centos:7
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

RUN yum -y install epel-release && \
    yum -y install awstats httpd && \
    yum clean all

# Log to stdout/stderr, copied from
# https://github.com/docker-library/httpd/blob/0e4a0b59e1f4e2a5a14ca197516beb2d4df1ffb8/2.4/alpine/Dockerfile#L78
RUN \
    sed -i "s/Require local/Require all granted/" /etc/httpd/conf.d/awstats.conf && \
    sed -ri \
        -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
        -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
        /etc/httpd/conf/httpd.conf && \
    echo "RedirectMatch ^/$ /awstats/awstats.pl" > /etc/httpd/conf.d/welcome.conf
COPY entrypoint.sh /

#USER
# Awstats are cached here
VOLUME ["/var/lib/awstats/"]

ENTRYPOINT ["/entrypoint.sh"]
