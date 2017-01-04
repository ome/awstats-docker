# Awstats Docker

Generate web server statistics using Awstats, run Apache so they can be viewed.

If you want a persistent cache ensure `/var/lib/awstats` is a volume.
Apache authentication is not enabled.


## Example

    docker run -it --rm -p 8080:80 \
        -v /data/web-logs:/web-logs:ro \
        -v awstats-var-lib:/var/lib/awstats \
        awstats '/web-logs/access.log-*.gz'

This will generate or update the web log statistics (may take a while), using the named volume `awstats-var-lib`.
Once this is done Apache will be started and Awstats can be accessed at http://localhost:8080
