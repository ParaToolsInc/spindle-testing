#!/bin/bash

# This is based on the Flux Container Tutorial
# See https://flux-framework.readthedocs.io/en/latest/tutorials/containers

brokerOptions="-Scron.directory=/etc/flux/system/cron.d \
  -Stbon.fanout=256 \
  -Srundir=/run/flux \
  -Sstatedir=${STATE_DIRECTORY:-/var/lib/flux} \
  -Slocal-uri=local:///run/flux/local \
  -Slog-stderr-level=6 \
  -Slog-stderr-mode=local"

address=$(echo $( nslookup "$( hostname -i )" | head -n 1 ))
parts=(${address//=/ })
hostName=${parts[2]}
thisHost=(${hostName//./ })
thisHost=${thisHost[0]}
echo $thisHost

export FLUX_FAKE_HOSTNAME=$thisHost

sudo -u munge /usr/sbin/munged

if [ ${thisHost} != "${mainHost}" ]; then
    # Worker nodes
    sleep 15
    FLUX_FAKE_HOSTNAME=$thisHost flux start -o --config /etc/flux/config ${brokerOptions} sleep inf
else
    # Head nodes
    FLUX_FAKE_HOSTNAME=$thisHost flux start -o --config /etc/flux/config ${brokerOptions} sleep inf
fi

