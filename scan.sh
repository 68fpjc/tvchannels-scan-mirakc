#! /bin/sh

{
  # GR
  for I in $(seq 13 62) ; do
    CH=${I}
    echo GR: ${CH} ... >&2
    echo {
    echo "\"type\":\"GR\",\"channel\":\"${CH}\",\"services\":"
    docker run --rm --device /dev/px4video2 -i --entrypoint /usr/bin/env mirakc/mirakc:alpine /bin/ash <<EOF
recpt1 --device /dev/px4video2 ${CH} 30 - | mirakc-arib scan-services || echo []
EOF
    echo }
  done

  # BS
  for I in $(seq -w 1 2 23); do
    for J in $(seq 0 3); do
      CH=BS${I}_${J}
      echo BS: ${CH} ... 1>&2
      echo {
      echo "\"type\":\"BS\",\"channel\":\"${CH}\",\"services\":"
    docker run --rm --device /dev/px4video0 -i --entrypoint /usr/bin/env mirakc/mirakc:alpine /bin/ash <<EOF
recpt1 --device /dev/px4video0 --lnb 15 ${CH} 30 - | mirakc-arib scan-services || echo []
EOF
      echo }
    done
  done

  # CS
  for I in $(seq 2 2 24); do
    CH=CS${I}
    echo CS: ${CH} ... >&2
    echo {
    echo "\"type\":\"CS\",\"channel\":\"${CH}\",\"services\":"
    docker run --rm --device /dev/px4video0 -i --entrypoint /usr/bin/env mirakc/mirakc:alpine /bin/ash <<EOF
recpt1 --device /dev/px4video0 --lnb 15 ${CH} 30 - | mirakc-arib scan-services || echo []
EOF
    echo }
  done
} | jq -s '[.[] | select((.services | length) > 0)]'
