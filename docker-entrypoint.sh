#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
	echo "$0: assuming arguments for dogecoind"
	set -- dogecoind "$@"
fi

# Allow the container to be started with `--user`, if running as root drop privileges
if [ "$1" = 'dogecoind' -a "$(id -u)" = '0' ]; then
	# Set perms on data
	echo "$0: detected dogecoind"
	mkdir -p "$DATADIR"
	chmod 700 "$DATADIR"
	chown -R dogecoin "$DATADIR"
	exec gosu dogecoin "$0" "$@" -datadir=$DATADIR
fi

if [ "$1" = 'dogecoin-cli' -a "$(id -u)" = '0' ] || [ "$1" = 'dogecoin-tx' -a "$(id -u)" = '0' ]; then
	echo "$0: detected dogecoin-cli or dogecoint-tx"
	exec gosu dogecoin "$0" "$@" -datadir=$DATADIR
fi

# If not root (i.e. docker run --user $USER ...), then run as invoked
echo "$0: running exec"
exec "$@"
