# Awstats Docker


Generate web server statistics using Awstats.
The generation of Awstats statistics is decoupled from the Awstats web interface.

`/var/lib/awstats` should be a persistent volume.


## Usage

Create a named volume:

    docker volume create --name awstats-db

Generate or update web log statistics in `awstats-db`.
The names of the log files to be processed should be passed as command line arguments, wildcards will be expanded.
If you are updating existing statistics ensure you follow the Awstats rules on ordering.
For example, if the web logs are `/data/web-logs/access.log-*.gz`:

    docker run -it --rm \
        -v /data/web-logs:/web-logs:ro -v awstats-db:/var/lib/awstats \
        REPOSITORY/awstats /web-logs/access.log-\*.gz

Run the Awstats web interface by passing no arguments:

    docker run -it --rm -p 8080:8080 -v awstats-db:/var/lib/awstats awstats

Awstats should now be accessible at http://localhost:8080.
Apache authentication is not enabled.

You can update the web log statistics in `awstats-db` by re-running with the new log files (Awstats will automatically skip duplicate entries, for example if you pass a log file that has already been processed).
The new logs must be [newer than the existing ones](http://www.awstats.org/docs/awstats_faq.html#OLDLOG):

    docker run -it --rm \
        -v /data/web-logs-new:/web-logs-new:ro -v awstats-db:/var/lib/awstats \
        REPOSITORY/awstats '/web-logs-new/access.log-*.gz'
