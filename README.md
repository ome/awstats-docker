# Awstats Docker

[![Build Status](https://travis-ci.org/openmicroscopy/awstats-docker.svg?branch=master)](https://travis-ci.org/openmicroscopy/awstats-docker)

Generate web server statistics using Awstats.
The generation of Awstats statistics is decoupled from the Awstats web interface.

`/var/lib/awstats` should be a persistent volume.


## Usage

Create a named volume:

    docker volume create --name awstats-db

Generate web log statistics in `awstats-db`.
The names of the log files to be processed should be passed as command line arguments, wildcards will be expanded.
For example, if the web logs are `/data/web-logs/access.log-*.gz`:

    docker run --rm -v /data/web-logs:/web-logs:ro -v awstats-db:/var/lib/awstats \
        openmicroscopy/awstats /web-logs/access.log-\*.gz

Run the Awstats web interface by passing just `httpd` as an argument:

    docker run --rm -p 8080:8080 -v awstats-db:/var/lib/awstats openmicroscopy/awstats httpd

Awstats should now be accessible at http://localhost:8080.
Apache authentication is not enabled.

You can update the web log statistics in `awstats-db` by re-running with the new log files (Awstats will automatically skip duplicate entries, for example if you pass a log file that has already been processed).
The new logs must be [newer than the existing ones](http://www.awstats.org/docs/awstats_faq.html#OLDLOG):

    docker run --rm -v /data/web-logs-new:/web-logs-new:ro -v awstats-db:/var/lib/awstats \
        openmicroscopy/awstats '/web-logs-new/access.log-\*.gz'


## Configuration

The configuration file `/etc/awstats/awstats.SITE_DOMAIN.conf` will be automatically generated at runtime if it doesn't exist.
The generated configuration can be modified using the following optional environment variables, see `entrypoint.pl` for defaults.
- `SITE_DOMAIN`: The site domain, default `localhost`.
  If you change this you must set the `config=` query parameter when using the web interface, e.g. http://localhost:8080/awstats/awstats.pl?config=SITE_DOMAIN (this is intended to support statistics for multiple domains)
- `SKIP_USER_AGENTS`: A space separated list of user agents, default `Travis Hudson`
- `SKIP_HOSTS`: A space separated list of regex IP matches to be skipped, default are private IP ranges and some Travis IPs.
- `SKIP_HOSTS_ADDITIONAL`: A space separated list of regex IP matches to be skipped in addition to the default `SKIP_HOSTS`
  This is provided so that you can add additional regexs to the default `SKIP_HOSTS` instead of having to define the full set.
- `LOG_FORMAT`: Set the `LogFormat` value. If quotes are desired, they should be added by the caller: `-e LOG_FORMAT=\"...\"`

For example

    docker run -e SKIP_HOSTS_ADDITIONAL="^1\.1\.  ^2\.2\. " \
        ... openmicroscopy/awstats ...

will skip IPs matching `^1\.1\.` `^2\.2\.` in addition to the defaults.

Alternatively you can provide a full configuration by mounting `/etc/awstats` into the container.
If no logfiles are passed on the command line the `LogFile` configuration option will be used.
