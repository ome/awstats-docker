#!/bin/sh

LOG_FILES="$@"

SITE_DOMAIN="localhost"

if [ ! -e "/etc/awstats/awstats.${SITE_DOMAIN}.conf" ]; then
    echo "Creating awstats.${SITE_DOMAIN}.conf"
    sed -r \
        -e "s%^LogFile=.*%LogFile=/dev/null%" \
        -e "s/^SiteDomain=.*/SiteDomain=\"${SITE_DOMAIN}\"/" \
        -e "s/^AllowFullYearView=.*/AllowFullYearView=3/" \
        -e "s/^BuildReportFormat=.*/BuildReportFormat=xhtml/" \
        /etc/awstats/awstats.model.conf > "/etc/awstats/awstats.${SITE_DOMAIN}.conf"

    #    AllowToUpdateStatsFromBrowser=1
fi

if [ -z "${LOG_FILES}" ]; then
    echo "No log files provided, starting httpd awstats"
    exec /usr/sbin/httpd -DFOREGROUND
else
    echo "Updating log statistics"
    # See /usr/share/awstats/wwwroot/cgi-bin/awstats.pl --help
    exec /usr/share/awstats/wwwroot/cgi-bin/awstats.pl \
        -config="${SITE_DOMAIN}" \
        -update \
        -showsteps \
        -showcorrupted \
        -showdropped \
        -showunknownorigin \
        -LogFile="/usr/share/awstats/tools/logresolvemerge.pl ${LOG_FILES} |"

    #    -showdirectorigin \
    #    -output=x
fi
