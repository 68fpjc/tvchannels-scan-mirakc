#! /bin/sh

mkdir -p logos/

TMPFILE=$(mktemp)
cat - >"${TMPFILE}"

# GR
for CH in "" $(cat "${TMPFILE}" | jq -r '.[] | select(.type == "GR") | .channel') ; do
  [ -n "${CH}" ] && {
    echo GR: ${CH} .. >&2
    {
    docker run --rm --device /dev/px4video2 -i --entrypoint /usr/bin/env mirakc/mirakc:alpine /bin/ash <<EOF
recpt1 --device /dev/px4video2 ${CH} 10m - | mirakc-arib collect-logos
EOF
    } | sort | uniq | jq -s '[.[]]' >logos/GR-${CH}.json
  }
done

# BS
for CH in "" $(cat "${TMPFILE}" | jq -r '.[] | select(.type == "BS" and .services[].name == "ＮＨＫＢＳ１") | .channel' | head -n 1) ; do
  [ -n "${CH}" ] && {
    echo BS: ${CH} .. >&2
    {
      docker run --rm --device /dev/px4video0 -i --entrypoint /usr/bin/env mirakc/mirakc:alpine /bin/ash <<EOF
recpt1 --device /dev/px4video0 --lnb 15 ${CH} 30m - | mirakc-arib collect-logos
EOF
    } | sort | uniq | jq -s '[.[]]' >>logos/BS-${CH}.json
  }
done

rm "${TMPFILE}"
