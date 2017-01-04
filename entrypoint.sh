#!/bin/sh

LOG_FILES="$@"

if [ -z "${LOG_FILES}" ]; then
    echo "ERROR: Logfiles required"
    exit 2
fi

SITE_DOMAIN="localhost"

sed -r \
    -e "s%^LogFile=.*%LogFile=/dev/null%" \
    -e "s/^SiteDomain=.*/SiteDomain=\"${SITE_DOMAIN}\"/" \
    -e "s/^AllowFullYearView=.*/AllowFullYearView=3/" \
    -e "s/^BuildReportFormat=.*/BuildReportFormat=xhtml/" \
    /etc/awstats/awstats.model.conf > "/etc/awstats/awstats.${SITE_DOMAIN}.conf"

#AllowToUpdateStatsFromBrowser=1

# Update stats
# See /usr/share/awstats/wwwroot/cgi-bin/awstats.pl --help
/usr/share/awstats/wwwroot/cgi-bin/awstats.pl -config="${SITE_DOMAIN}" \
    -update \
    -showsteps \
    -showcorrupted \
    -showdropped \
    -showunknownorigin \
    -LogFile="/usr/share/awstats/tools/logresolvemerge.pl ${LOG_FILES} |"

#    -showdirectorigin \
#    -output=x

exec /usr/sbin/httpd -DFOREGROUND
