## MediaWiki

A self-contained instance of MediaWiki with data volume support. Based on the work by
[Nick Stenning](https://github.com/nickstenning/dockerfiles/tree/master/mediawiki).

This image contains a basic installation of [MediaWiki][mw], powered by [nginx][nginx],
[php-fpm][php-fpm], and [sqlite][sqlite].

The setup requires LocalSettings.php`and
wiki.sqlite. You can run the MediaWiki installer to configure your wiki. In the alternative,
you can copy the files in bootstrap to /data/wiki and your wiki will spin up with a default
database and settings.

The README.md in Nick Stenning's repo has instructions for creating your own LocalSettings.php
using the MediaWiki installer.

By default, MediaWiki uploads will also be written to the `images/` directory of
the mounted data volume. This directory will be created if necessary on startup.

### Technical details

The web server is [nginx][nginx]. Its configuration file works with php-fpm by
listening on a unix socket.

MediaWiki is based on php so the Dockerfile installs php5 and appropriate packages.

The database is sqlite. Since this is a file-based database, a bootstrapped file is
provided to get you going. Appropriate php5 packages are installed to work with 
sqlite.

Supervisor controls the server processes. The Docker [ENTRYPOINT](https://docs.docker.com/reference/builder/#entrypoint)
launches supervisor to initialize the services.
